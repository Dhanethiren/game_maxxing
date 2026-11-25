/*
 * Sound core: deterministic DSP building blocks plus the engine that turns a
 * project's sound config (sounds.config.js) into audio.
 *
 * The same file runs in Node (render.js writes the .wav files) and in the
 * browser (the Sound Studio page, where people listen and move sliders), so
 * what someone hears in the studio is exactly what ships. Everything is
 * seeded: the same settings always give the same samples.
 *
 * Browser: defines window.SoundCore.  Node: module.exports.
 */
(function (root, factory) {
  if (typeof module === 'object' && module.exports) module.exports = factory();
  else root.SoundCore = factory();
})(typeof self !== 'undefined' ? self : this, function () {
  'use strict';

  const TAU = 2 * Math.PI;

  // ------------------------------------------------------------ randomness

  /** Seeded generator (mulberry32). Never use Math.random in a recipe. */
  function rngFor(seed) {
    let a = seed >>> 0;
    return function () {
      a = (a + 0x6d2b79f5) | 0;
      let t = Math.imul(a ^ (a >>> 15), 1 | a);
      t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
      return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
    };
  }

  /** Normal-distributed sample from a seeded generator. */
  function gauss(rng) {
    let u = 0;
    while (u === 0) u = rng();
    return Math.sqrt(-2 * Math.log(u)) * Math.cos(TAU * rng());
  }

  /** White noise, `sec` long, from a seed. */
  function noise(sec, sr, seed) {
    const rng = rngFor(seed === undefined ? 1 : seed);
    const x = silence(sec, sr);
    for (let i = 0; i < x.length; i++) x[i] = gauss(rng);
    return x;
  }

  // ----------------------------------------------------------------- pitch

  const SCALES = {
    majorPentatonic: [0, 2, 4, 7, 9],
    minorPentatonic: [0, 3, 5, 7, 10],
    major: [0, 2, 4, 5, 7, 9, 11],
    minor: [0, 2, 3, 5, 7, 8, 10],
    dorian: [0, 2, 3, 5, 7, 9, 10],
    mixolydian: [0, 2, 4, 5, 7, 9, 10],
    lydian: [0, 2, 4, 6, 7, 9, 11],
    harmonicMinor: [0, 2, 3, 5, 7, 8, 11],
    wholeTone: [0, 2, 4, 6, 8, 10],
    chromatic: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
  };
  const NOTE_NAMES = ['C', 'C♯', 'D', 'D♯', 'E', 'F', 'F♯', 'G', 'G♯', 'A', 'A♯', 'B'];

  /** Frequency of a MIDI note (60 = middle C), optionally transposed. */
  function midiHz(m, transpose) {
    return 440 * Math.pow(2, (m + (transpose || 0) - 69) / 12);
  }

  function midiName(m) {
    const r = Math.round(m);
    return NOTE_NAMES[((r % 12) + 12) % 12] + (Math.floor(r / 12) - 1);
  }

  /**
   * MIDI note of scale degree i. scale = { root: 60, steps: [0,2,4,7,9] }.
   * Degrees wrap into octaves: with 5 steps, i = 5 is the root an octave up.
   */
  function scaleMidi(i, scale) {
    const steps = scale.steps;
    const n = steps.length;
    const o = Math.floor(i / n);
    const s = ((i % n) + n) % n;
    return scale.root + 12 * o + steps[s];
  }

  function scaleHz(i, scale, transpose) {
    return 440 * Math.pow(2, (scaleMidi(i, scale) + (transpose || 0) - 69) / 12);
  }

  function scaleNoteName(i, scale) {
    return midiName(scaleMidi(Math.round(i), scale));
  }

  // --------------------------------------------------------------- buffers

  function silence(sec, sr) {
    return new Float32Array(Math.max(1, Math.round(sec * sr)));
  }

  /** Adds `sig` into `out` starting at `atSec`, scaled by `gain`. */
  function mixInto(out, sig, atSec, sr, gain) {
    const g = gain === undefined ? 1 : gain;
    const i0 = Math.round(atSec * sr);
    const n = Math.min(sig.length, out.length - i0);
    for (let i = 0; i < n; i++) out[i0 + i] += sig[i] * g;
  }

  /** events: [[atSec, signal, gain], ...] mixed into one buffer. */
  function sequence(events, totalSec, sr) {
    const out = silence(totalSec, sr);
    for (const e of events) mixInto(out, e[1], e[0], sr, e[2]);
    return out;
  }

  // --------------------------------------------------------------- filters

  /** One-pole low-pass (6 dB/oct). */
  function lowpass(x, fc, sr) {
    const a = 1 - Math.exp((-2 * Math.PI * fc) / sr);
    const o = new Float32Array(x.length);
    let y = 0;
    for (let i = 0; i < x.length; i++) {
      y += a * (x[i] - y);
      o[i] = y;
    }
    return o;
  }

  /** Two one-pole stages: a softer, warmer roll-off (12 dB/oct). */
  function warm(x, fc, sr) {
    return lowpass(lowpass(x, fc, sr), fc, sr);
  }

  /** One-pole high-pass: the input minus its low-passed self. */
  function highpass(x, fc, sr) {
    const l = lowpass(x, fc, sr);
    const o = new Float32Array(x.length);
    for (let i = 0; i < x.length; i++) o[i] = x[i] - l[i];
    return o;
  }

  /** Steep band: 12 dB/oct below `lo`, 24 dB/oct above `hi`. Good for whooshes. */
  function bandpass(x, lo, hi, sr) {
    const top = warm(warm(x, hi, sr), hi, sr);
    const bottom = warm(x, lo, sr);
    const o = new Float32Array(x.length);
    for (let i = 0; i < x.length; i++) o[i] = top[i] - bottom[i];
    return o;
  }

  /** Mono Freeverb-style room: 8 damped combs + 4 allpasses. */
  function reverb(x, opts) {
    const sr = opts.sr;
    const wet = opts.wet;
    if (!(wet > 0)) return x;
    const size = opts.size === undefined ? 0.84 : opts.size;
    const damp = opts.damp === undefined ? 0.4 : opts.damp;
    const n = x.length + Math.round((opts.tail || 1.2) * sr);
    const input = new Float32Array(n);
    input.set(x);
    const k = sr / 44100;
    const combs = [1116, 1188, 1277, 1356, 1422, 1491, 1557, 1617].map(function (t) {
      return { buf: new Float32Array(Math.max(1, Math.round(t * k))), i: 0, s: 0 };
    });
    const aps = [556, 441, 341, 225].map(function (t) {
      return { buf: new Float32Array(Math.max(1, Math.round(t * k))), i: 0 };
    });
    const out = new Float32Array(n);
    for (let i = 0; i < n; i++) {
      const inp = input[i] * 0.015;
      let acc = 0;
      for (let c = 0; c < 8; c++) {
        const cb = combs[c];
        const y = cb.buf[cb.i];
        cb.s = y * (1 - damp) + cb.s * damp;
        cb.buf[cb.i] = inp + cb.s * size;
        if (++cb.i >= cb.buf.length) cb.i = 0;
        acc += y;
      }
      for (let a = 0; a < 4; a++) {
        const ap = aps[a];
        const b = ap.buf[ap.i];
        const y = b - acc;
        ap.buf[ap.i] = acc + b * 0.5;
        if (++ap.i >= ap.buf.length) ap.i = 0;
        acc = y;
      }
      out[i] = input[i] * (1 - wet) + acc * wet * 3;
    }
    return out;
  }

  // ------------------------------------------------------------ envelopes

  /** Linear fade-in over `sec` (in place). Removes the click at the start. */
  function attack(x, sec, sr) {
    const n = Math.min(x.length, Math.round(sec * sr));
    for (let i = 0; i < n; i++) x[i] *= i / n;
    return x;
  }

  /** Linear fade-out over the last `sec` (in place). */
  function fadeOut(x, sec, sr) {
    const n = Math.min(x.length, Math.round(sec * sr));
    for (let i = 0; i < n; i++) x[x.length - 1 - i] *= i / n;
    return x;
  }

  /**
   * The last step of every one-shot sound: remove DC offset, scale the peak
   * to `peak` (keep it <= 0.9 for headroom), trim the silent tail and fade
   * the last 20 ms.
   */
  function finish(x, peak, sr) {
    let mean = 0;
    for (let i = 0; i < x.length; i++) mean += x[i];
    mean /= x.length || 1;
    let max = 1e-9;
    for (let i = 0; i < x.length; i++) {
      x[i] -= mean;
      max = Math.max(max, Math.abs(x[i]));
    }
    const g = peak / max;
    let last = 0;
    for (let i = 0; i < x.length; i++) {
      x[i] *= g;
      if (Math.abs(x[i]) > 1e-3) last = i;
    }
    const fade = Math.round(0.02 * sr);
    const end = Math.min(x.length, last + fade + 1);
    const out = x.slice(0, end);
    for (let i = 0; i < fade && i < out.length; i++) {
      out[out.length - 1 - i] *= i / fade;
    }
    return out;
  }

  /** DC removal and peak scaling without trimming (for loops). */
  function peakNormalize(x, peak) {
    let mean = 0;
    let max = 1e-9;
    for (let i = 0; i < x.length; i++) mean += x[i];
    mean /= x.length || 1;
    for (let i = 0; i < x.length; i++) {
      x[i] -= mean;
      max = Math.max(max, Math.abs(x[i]));
    }
    for (let i = 0; i < x.length; i++) x[i] *= peak / max;
    return x;
  }

  /**
   * Makes a seamless loop of `loopSec`: everything after the loop point
   * (reverb tails, ringing notes) is folded back onto the start, so the end
   * flows into the beginning with no click or gap. Render a few seconds
   * longer than the loop, then fold.
   */
  function loopFold(x, loopSec, sr) {
    const L = Math.round(loopSec * sr);
    const loop = x.slice(0, L);
    for (let i = L; i < x.length && i - L < L; i++) loop[i - L] += x[i];
    return loop;
  }

  // ---------------------------------------------------------------- voices

  /**
   * Soft glassy bell / celesta: a few inharmonic partials with their own
   * decays. `bright` (0..2) raises the upper partials.
   */
  function bell(freq, dur, bright, sr) {
    const parts = [
      [1, 1, 1],
      [2, 0.42, 0.65],
      [3, 0.2, 0.45],
      [4.17, 0.1 * bright, 0.3],
      [5.43, 0.05 * bright, 0.2],
    ];
    const n = Math.round(dur * sr);
    const out = new Float32Array(n);
    for (const p of parts) {
      const f = freq * p[0];
      if (f > sr / 2.2) continue;
      const tau = dur * 0.28 * p[2];
      const w = (2 * Math.PI * f) / sr;
      for (let i = 0; i < n; i++) {
        out[i] += p[1] * Math.sin(w * i) * Math.exp(-i / sr / tau);
      }
    }
    const att = Math.round(0.004 * sr);
    for (let i = 0; i < att && i < n; i++) out[i] *= i / att;
    return out;
  }

  const WAVES = {
    sine: function (p) { return Math.sin(TAU * p); },
    triangle: function (p) { return 4 * Math.abs(p - 0.5) - 1; },
    square: function (p) { return p < 0.5 ? 1 : -1; },
    saw: function (p) { return 2 * p - 1; },
  };

  /**
   * A single synth note with a pitch glide and exponential decay: taps,
   * pops, blips, jumps, lasers, UI ticks.
   *   { freq, freqEnd, glide (s), dur (s), decay (s), shape, attack (s), sr }
   * square/saw alias at high pitch: low-pass them (e.g. warm(x, 3000, sr)).
   */
  function blip(o) {
    const sr = o.sr;
    const n = Math.max(1, Math.round(o.dur * sr));
    const f0 = o.freq;
    const f1 = o.freqEnd === undefined ? o.freq : o.freqEnd;
    const glide = o.glide || o.dur * 0.3;
    const tau = o.decay || o.dur / 4;
    const wave = WAVES[o.shape || 'sine'] || WAVES.sine;
    const out = new Float32Array(n);
    let ph = 0;
    for (let i = 0; i < n; i++) {
      const t = i / sr;
      ph += (f1 + (f0 - f1) * Math.exp(-t / glide)) / sr;
      ph -= Math.floor(ph);
      out[i] = wave(ph) * Math.exp(-t / tau);
    }
    return attack(out, o.attack === undefined ? 0.002 : o.attack, sr);
  }

  /**
   * Plucked string (Karplus-Strong): warm, organic, good for cozy games.
   *   opts: { decay: 0.990..0.999 (higher rings longer), blend: 0..1
   *           (0.5 = classic, lower = brighter), seed }
   * Pitch is rounded to a whole-sample delay, so very high notes drift a
   * little; keep it under ~1.5 kHz.
   */
  function pluck(freq, dur, sr, opts) {
    const o = opts || {};
    const rng = rngFor(o.seed === undefined ? 7 : o.seed);
    const N = Math.max(2, Math.round(sr / freq));
    const buf = new Float32Array(N);
    for (let k = 0; k < N; k++) buf[k] = rng() * 2 - 1;
    const damp = o.decay === undefined ? 0.996 : o.decay;
    const blend = o.blend === undefined ? 0.5 : o.blend;
    const n = Math.max(1, Math.round(dur * sr));
    const out = new Float32Array(n);
    let idx = 0;
    for (let i = 0; i < n; i++) {
      const a = buf[idx];
      const b = buf[(idx + 1) % N];
      out[i] = a;
      buf[idx] = damp * ((1 - blend) * a + blend * b);
      idx = (idx + 1) % N;
    }
    return attack(out, 0.001, sr);
  }

  /**
   * Soft pad note for music beds: three slightly detuned sines plus an
   * octave, slow attack/release and a gentle tremolo.
   *   opts: { attack (s), release (s), detune: [..], harmonic2, tremolo }
   */
  function padNote(freq, dur, sr, opts) {
    const o = opts || {};
    const att = o.attack === undefined ? 1 : o.attack;
    const rel = o.release === undefined ? 1 : o.release;
    const detune = o.detune || [-0.0018, 0, 0.0021];
    const h2 = o.harmonic2 === undefined ? 0.18 : o.harmonic2;
    const trem = o.tremolo === undefined ? 0.06 : o.tremolo;
    const n = Math.round(dur * sr);
    const sig = new Float32Array(n);
    detune.forEach(function (d) {
      const w = (2 * Math.PI * freq * (1 + d)) / sr;
      for (let i = 0; i < n; i++) {
        sig[i] += Math.sin(w * i) + h2 * Math.sin(2 * w * i);
      }
    });
    for (let i = 0; i < n; i++) {
      const t = i / sr;
      const env = Math.min(1, t / att) * Math.max(0, Math.min(1, (dur - t) / rel));
      const tr = 1 + trem * Math.sin(2 * Math.PI * 0.17 * t + freq);
      sig[i] *= (env * tr) / detune.length;
    }
    return sig;
  }

  /**
   * Short filtered noise burst: hits, clicks, footsteps, paper, hi-hats.
   *   { dur, decay (s), tone (low-pass Hz) | low + high (band, Hz), seed, sr }
   */
  function noiseHit(o) {
    const sr = o.sr;
    const x = noise(o.dur, sr, o.seed === undefined ? 3 : o.seed);
    const tau = o.decay || o.dur / 5;
    for (let i = 0; i < x.length; i++) x[i] *= Math.exp(-i / sr / tau);
    const shaped = o.high ? bandpass(x, o.low || 100, o.high, sr) : lowpass(x, o.tone || 2500, sr);
    return attack(shaped, o.attack === undefined ? 0.0008 : o.attack, sr);
  }

  // ------------------------------------------------------------------- wav

  /** 16-bit PCM mono WAV bytes. */
  function wav(samples, sampleRate) {
    const n = samples.length;
    const buf = new ArrayBuffer(44 + n * 2);
    const v = new DataView(buf);
    const str = function (o, s) {
      for (let i = 0; i < s.length; i++) v.setUint8(o + i, s.charCodeAt(i));
    };
    str(0, 'RIFF');
    v.setUint32(4, 36 + n * 2, true);
    str(8, 'WAVE');
    str(12, 'fmt ');
    v.setUint32(16, 16, true);
    v.setUint16(20, 1, true);
    v.setUint16(22, 1, true);
    v.setUint32(24, sampleRate, true);
    v.setUint32(28, sampleRate * 2, true);
    v.setUint16(32, 2, true);
    v.setUint16(34, 16, true);
    str(36, 'data');
    v.setUint32(40, n * 2, true);
    for (let i = 0; i < n; i++) {
      const x = Math.max(-1, Math.min(1, samples[i]));
      v.setInt16(44 + i * 2, Math.round(x * 32767), true);
    }
    return new Uint8Array(buf);
  }

  // ---------------------------------------------------------------- engine

  /*
   * Param spec: [default, min, max, step, unit, label, options?]
   *   unit: 'Hz' 'ms' 's' '%' '×' 'dB' 'semitones' 'note' (a scale degree,
   *   shown as a note name) 'count' 'choice' (options = list of labels) or ''.
   */
  function validate(config) {
    const errs = [];
    if (!config || !Array.isArray(config.sounds) || !config.sounds.length) {
      throw new Error('sounds config: `sounds` must be a non-empty array');
    }
    const keys = {};
    const files = {};
    function checkSpec(where, k, spec) {
      if (!Array.isArray(spec) || spec.length < 6) {
        errs.push(where + '.' + k + ': spec must be [default, min, max, step, unit, label]');
        return;
      }
      if (!(spec[1] <= spec[0] && spec[0] <= spec[2])) {
        errs.push(where + '.' + k + ': default ' + spec[0] + ' is outside ' + spec[1] + '..' + spec[2]);
      }
      if (!(spec[3] > 0)) errs.push(where + '.' + k + ': step must be > 0');
      if (spec[4] === 'choice' && !(Array.isArray(spec[6]) && spec[6].length === spec[2] - spec[1] + 1)) {
        errs.push(where + '.' + k + ': choice needs an options list with one label per value');
      }
    }
    for (const k in config.global || {}) checkSpec('global', k, config.global[k]);
    config.sounds.forEach(function (s, n) {
      const where = s && s.key ? s.key : 'sounds[' + n + ']';
      if (!s || !s.key) errs.push(where + ': missing key');
      else if (keys[s.key]) errs.push(where + ': duplicate key');
      else keys[s.key] = true;
      if (typeof s.render !== 'function') errs.push(where + ': missing render(p, g, x)');
      if (!Array.isArray(s.files) || !s.files.length) errs.push(where + ': files must list at least one name');
      (s.files || []).forEach(function (f) {
        if (!/^[A-Za-z0-9_-]+$/.test(f)) errs.push(where + ': file name "' + f + '" should be letters, digits, _ or -');
        if (files[f]) errs.push(where + ': file "' + f + '" is also made by ' + files[f]);
        files[f] = where;
      });
      for (const k in s.params || {}) checkSpec(where, k, s.params[k]);
    });
    (config.scenarios || []).forEach(function (sc) {
      (sc.events || []).forEach(function (e) {
        if (!keys[e[1]]) errs.push('scenario "' + sc.name + '": unknown sound "' + e[1] + '"');
      });
    });
    if (errs.length) throw new Error('sounds config problems:\n  - ' + errs.join('\n  - '));
  }

  function createEngine(config) {
    validate(config);
    const SOUNDS = config.sounds;
    const GLOBAL = config.global || {};
    const SCALE = config.scale || { root: 60, steps: SCALES.majorPentatonic };
    const SR = config.sampleRate || 44100;
    const byKey = {};
    SOUNDS.forEach(function (s) { byKey[s.key] = s; });

    function defaults() {
      const out = { version: 1, global: {}, sounds: {} };
      for (const k in GLOBAL) out.global[k] = GLOBAL[k][0];
      for (const s of SOUNDS) {
        out.sounds[s.key] = {};
        for (const k in s.params || {}) out.sounds[s.key][k] = s.params[k][0];
      }
      return out;
    }

    /**
     * Fills missing values from the defaults and clamps to the ranges.
     * Accepts a studio save ({ settings, note, savedAt }) as well.
     */
    function normalize(settings) {
      let s = settings || {};
      if (s.settings && !s.sounds) s = s.settings;
      const d = defaults();
      for (const k in GLOBAL) {
        const r = GLOBAL[k];
        const v = s.global && typeof s.global[k] === 'number' ? s.global[k] : r[0];
        d.global[k] = Math.min(r[2], Math.max(r[1], v));
      }
      for (const snd of SOUNDS) {
        for (const k in snd.params || {}) {
          const r = snd.params[k];
          const src = s.sounds && s.sounds[snd.key];
          const v = src && typeof src[k] === 'number' ? src[k] : r[0];
          d.sounds[snd.key][k] = Math.min(r[2], Math.max(r[1], v));
        }
      }
      return d;
    }

    function sampleRateOf(key) {
      return byKey[key].sampleRate || SR;
    }

    /**
     * Renders file `fileIndex` of sound `key` (the variant or level).
     * Returns { sampleRate, samples }.
     */
    function render(key, settings, fileIndex) {
      const snd = byKey[key];
      if (!snd) throw new Error('unknown sound "' + key + '"');
      const s = normalize(settings);
      const g = s.global;
      const sr = sampleRateOf(key);
      const transpose = g.transpose || 0;
      const x = {
        index: fileIndex || 0,
        sr: sr,
        core: api,
        scale: SCALE,
        settings: s,
        /** Hz of scale degree i in the project's scale, with the global key shift. */
        hz: function (i) { return scaleHz(i, SCALE, transpose); },
        /** Hz of a MIDI note with the global key shift. */
        midi: function (m) { return midiHz(m, transpose); },
      };
      const samples = snd.render(s.sounds[key], g, x);
      if (!(samples instanceof Float32Array)) {
        throw new Error('sound "' + key + '": render must return a Float32Array');
      }
      return { sampleRate: sr, samples: samples };
    }

    /** In-game volume per file name (gameVolume param, default 1): mix.json. */
    function mix(settings) {
      const s = normalize(settings);
      const out = {};
      for (const snd of SOUNDS) {
        const gv = s.sounds[snd.key].gameVolume;
        for (const f of snd.files) out[f] = typeof gv === 'number' ? gv : 1;
      }
      return out;
    }

    return {
      TITLE: config.title || 'Game',
      CATALOGUE: SOUNDS,
      GLOBAL_PARAMS: GLOBAL,
      SCENARIOS: config.scenarios || [],
      SCALE: SCALE,
      config: config,
      defaults: defaults,
      normalize: normalize,
      render: render,
      mix: mix,
      wav: wav,
      noteName: function (i) { return scaleNoteName(i, SCALE); },
    };
  }

  const api = {
    // randomness
    rngFor: rngFor, gauss: gauss, noise: noise,
    // pitch
    SCALES: SCALES, midiHz: midiHz, midiName: midiName,
    scaleMidi: scaleMidi, scaleHz: scaleHz, scaleNoteName: scaleNoteName,
    // buffers and filters
    silence: silence, mixInto: mixInto, sequence: sequence,
    lowpass: lowpass, warm: warm, highpass: highpass, bandpass: bandpass, reverb: reverb,
    // envelopes and finishing
    attack: attack, fadeOut: fadeOut, finish: finish, peakNormalize: peakNormalize, loopFold: loopFold,
    // voices
    bell: bell, blip: blip, pluck: pluck, padNote: padNote, noiseHit: noiseHit, WAVES: WAVES,
    // output and engine
    wav: wav, validate: validate, createEngine: createEngine,
  };
  return api;
});
