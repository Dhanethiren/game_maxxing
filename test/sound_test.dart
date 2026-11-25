import 'dart:convert';
import 'dart:io';

import 'package:calm_grid/audio/sound_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Line clear sounds', () {
    test('every extra line at once plays its own, bigger sound', () {
      expect(SoundService.linesFile(1), isNull);
      expect(SoundService.linesFile(2), 'lines_2');
      expect(SoundService.linesFile(4), 'lines_4');
      expect(SoundService.linesFile(6), 'lines_6');
      // 6 is the most one block can clear; anything above shares the top sound.
      expect(SoundService.linesFile(9), 'lines_6');
    });

    test('the combo chime steps back under bigger moments', () {
      final volumes = [
        for (var l = 1; l <= 6; l++) SoundService.chimeVolume(l),
      ];
      for (var i = 1; i < volumes.length; i++) {
        expect(volumes[i], lessThanOrEqualTo(volumes[i - 1]));
      }
      expect(SoundService.chimeVolume(1), 1.0);
      expect(SoundService.chimeVolume(1, perfect: true), lessThan(1.0));
    });

    test('a perfect clear plays its own sound, not the multi-line one', () {
      final s = SilentSoundService();
      s.clear(lines: 3, combo: 2);
      expect(s.played, ['clear2', 'lines_3']);
      s.played.clear();
      s.clear(lines: 3, combo: 2, perfect: true);
      expect(s.played, ['clear2']);
      s.played.clear();
      s.clear(lines: 1, combo: 1);
      expect(s.played, ['clear1']);
    });
  });

  test('every sound the game loads exists and has an in-game volume', () {
    final mix = jsonDecode(
      File('assets/sounds/mix.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final names = [
      for (var i = 0; i < 3; i++) 'place_$i',
      for (var i = 1; i <= 8; i++) 'clear_$i',
      for (var n = 2; n <= 6; n++) 'lines_$n',
      for (final s in Sfx.values) s.file,
      'music_loop',
    ];
    for (final n in names) {
      expect(File('assets/sounds/$n.wav').existsSync(), isTrue, reason: n);
      expect(mix.containsKey(n), isTrue, reason: '$n missing from mix.json');
    }
  });
}
