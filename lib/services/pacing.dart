import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

/// Chooses one of a few styles for a recurring moment and learns from yes/no
/// answers, separately for a handful of coarse situations ("moods").
///
/// How it works (Thompson sampling with pooled priors):
/// * Every (slot, style, mood) keeps two numbers: how often the answer was
///   yes and how often no. Each fades slowly with its own new answers
///   ([_keep]), so it follows a player whose taste changes.
/// * A style's results across all moods form the prior for each mood, so a
///   new situation borrows what the style has shown elsewhere and learns fast
///   from very little data. That borrowing fades as the situation collects
///   answers of its own.
/// * To choose, it draws a plausible yes-rate for every style from its
///   (sharpened) Beta posterior and takes the highest: proven styles win most
///   of the time, uncertain ones still get tried now and then.
/// * [rest] lets a moment sit out when a player keeps saying no and nothing
///   is likely to change that. It never rests in high-stakes moods and never
///   more than twice in a row, so a "no" player is asked less, not nagged.
///
/// Everything stays on the device; the saved state is about 200 characters.
class Pacer {
  Pacer({Random? random, List<double>? base})
    : _random = random ?? Random(),
      _base = base ?? const [0.35, 0.25, 0.4];

  static const int slots = 3;
  static const int styles = 3;
  static const int moods = 4;

  /// Share of a cell's evidence kept each time it gets a new answer
  /// (a half-life of about 70 answers).
  static const double _keep = 0.99;

  /// How strongly a style's overall record shapes a mood with no answers of
  /// its own (in answers), and how fast that fades as answers arrive.
  static const double _poolWeight = 6;
  static const double _poolFade = 4;

  /// Draws come from a posterior this many times narrower: less exploring,
  /// which suits players who only see a few offers a day.
  ///
  /// These settings were tuned in simulation: 600 players with different
  /// tastes over their first 20, 60 and 150 offers, plus a hard case where a
  /// style is great in one mood and poor in another. They match the larger
  /// linear model this replaced (within a point) and beat random wording by
  /// 4 to 8 points.
  static const double _sharpen = 4;

  /// Consecutive "no" answers before a slot may rest, and the yes-rate under
  /// which resting is worth it.
  static const int _restAfter = 3;
  static const double _restBelow = 0.12;
  static const int _maxRestsInARow = 2;

  static const int _version = 1;
  static const int _scale = 256; // fixed-point resolution of saved counts

  final Random _random;

  /// Starting guess of the yes-rate for each slot.
  final List<double> _base;

  final Float64List _yes = Float64List(slots * styles * moods);
  final Float64List _no = Float64List(slots * styles * moods);
  final Uint8List _streak = Uint8List(slots); // consecutive "no" answers
  final Uint8List _rested = Uint8List(slots); // consecutive rests

  int _cell(int slot, int style, int mood) =>
      (slot * styles + style) * moods + mood;

  (double, double) _posterior(int slot, int style, int mood) {
    var y = 0.0;
    var n = 0.0;
    for (var m = 0; m < moods; m++) {
      y += _yes[_cell(slot, style, m)];
      n += _no[_cell(slot, style, m)];
    }
    final pooled = (y + 2 * _base[slot]) / (y + n + 2);
    final i = _cell(slot, style, mood);
    final k = _poolWeight * _poolFade / (_poolFade + _yes[i] + _no[i]);
    return (_yes[i] + k * pooled, _no[i] + k * (1 - pooled));
  }

  /// Expected yes-rate (0..1) of [style] at [slot] in [mood].
  double chance(int slot, int style, int mood) {
    final (a, b) = _posterior(slot, style, mood);
    return a / (a + b);
  }

  /// The style to use now: one draw from each style's posterior, best wins.
  int pick(int slot, int mood) {
    var best = 0;
    var top = -1.0;
    for (var s = 0; s < styles; s++) {
      final (a, b) = _posterior(slot, s, mood);
      final draw = _beta(a * _sharpen, b * _sharpen);
      if (draw > top) {
        top = draw;
        best = s;
      }
    }
    return best;
  }

  /// Records the answer to [style] at [slot] in [mood].
  void learn(int slot, int style, int mood, {required bool yes}) {
    final i = _cell(slot, style, mood);
    _yes[i] *= _keep;
    _no[i] *= _keep;
    if (yes) {
      _yes[i] += 1;
    } else {
      _no[i] += 1;
    }
    _streak[slot] = yes ? 0 : min(_streak[slot] + 1, 255);
    _rested[slot] = 0;
  }

  /// Whether [slot] should sit out this time. Counts the rest when it does.
  bool rest(int slot, int mood, {required bool highStakes}) {
    if (highStakes ||
        _streak[slot] < _restAfter ||
        _rested[slot] >= _maxRestsInARow) {
      return false;
    }
    for (var s = 0; s < styles; s++) {
      if (chance(slot, s, mood) >= _restBelow) return false;
    }
    _rested[slot]++;
    return true;
  }

  /// Compact state: a version byte, the counters, then every count as
  /// 16-bit fixed point, base64url-encoded.
  String save() {
    final n = _yes.length;
    final bytes = ByteData(1 + 2 * slots + 4 * n);
    var o = 0;
    bytes.setUint8(o++, _version);
    for (var s = 0; s < slots; s++) {
      bytes.setUint8(o++, _streak[s]);
      bytes.setUint8(o++, _rested[s]);
    }
    int fixed(double v) => (v * _scale).round().clamp(0, 65535);
    for (var i = 0; i < n; i++) {
      bytes.setUint16(o, fixed(_yes[i]));
      bytes.setUint16(o + 2, fixed(_no[i]));
      o += 4;
    }
    return base64Url.encode(bytes.buffer.asUint8List()).replaceAll('=', '');
  }

  /// Restores [save]d state. Starts fresh on missing, old or damaged data.
  void load(String? state) {
    if (state == null || state.isEmpty) return;
    try {
      final padded = state.padRight((state.length + 3) ~/ 4 * 4, '=');
      final raw = base64Url.decode(padded);
      final n = _yes.length;
      if (raw.length != 1 + 2 * slots + 4 * n || raw[0] != _version) return;
      final bytes = ByteData.sublistView(raw);
      var o = 1;
      for (var s = 0; s < slots; s++) {
        _streak[s] = bytes.getUint8(o++);
        _rested[s] = bytes.getUint8(o++);
      }
      for (var i = 0; i < n; i++) {
        _yes[i] = bytes.getUint16(o) / _scale;
        _no[i] = bytes.getUint16(o + 2) / _scale;
        o += 4;
      }
    } catch (_) {
      _yes.fillRange(0, _yes.length, 0);
      _no.fillRange(0, _no.length, 0);
      _streak.fillRange(0, slots, 0);
      _rested.fillRange(0, slots, 0);
    }
  }

  // Beta(a, b) as X / (X + Y) with X ~ Gamma(a), Y ~ Gamma(b).
  double _beta(double a, double b) {
    final x = _gamma(a);
    final y = _gamma(b);
    return x + y > 0 ? x / (x + y) : 0.5;
  }

  // Marsaglia–Tsang; shapes below 1 use the boost Gamma(k+1)·U^(1/k).
  double _gamma(double k) {
    if (k < 1) return _gamma(k + 1) * pow(_random.nextDouble(), 1 / k);
    final d = k - 1 / 3;
    final c = 1 / sqrt(9 * d);
    while (true) {
      double x;
      double v;
      do {
        x = _normal();
        v = 1 + c * x;
      } while (v <= 0);
      v = v * v * v;
      final u = _random.nextDouble();
      if (u < 1 - 0.0331 * x * x * x * x) return d * v;
      if (u > 0 && log(u) < 0.5 * x * x + d * (1 - v + log(v))) return d * v;
    }
  }

  double _normal() {
    var u = 0.0;
    while (u == 0) {
      u = _random.nextDouble();
    }
    return sqrt(-2 * log(u)) * cos(2 * pi * _random.nextDouble());
  }
}
