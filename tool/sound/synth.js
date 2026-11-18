/*
 * Calm Grid sound engine.
 *
 * The single source of truth for every sound in the game. The same file runs
 * in the browser (the Sound Studio page, where you tweak and listen) and in
 * Node (tool/sound/render.js, which writes assets/sounds/*.wav). Everything
 * is synthesised from parameters with a seeded random generator, so the same
 * settings always give exactly the same sound.
 */
(function (root, factory) {
  if (typeof module === 'object' && module.exports) module.exports = factory();
  else root.CalmSynth = factory();
})(typeof self !== 'undefined' ? self : this, function () {
  'use strict';

  const SR = 44100;
  const MUSIC_SR = 22050;
  const PENTA = [0, 2, 4, 7, 9];
  const NOTE_NAMES = ['C', 'D', 'E', 'G', 'A'];

  // ------------------------------------------------------------- helpers

  function rngFor(seed) {
    let a = seed >>> 0;
    return function () {
      a = (a + 0x6d2b79f5) | 0;
      let t = Math.imul(a ^ (a >>> 15), 1 | a);
      t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
      return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
    };
  }

  function gauss(rng) {
    let u = 0;
    while (u === 0) u = rng();
    return Math.sqrt(-2 * Math.log(u)) * Math.cos(2 * Math.PI * rng());
  }

  /** Frequency of the i-th note of C major pentatonic (i = 5 is C5). */
  function penta(i, transpose) {
    const o = Math.floor(i / 5);
    const step = ((i % 5) + 5) % 5;
    const midi = 60 + 12 * o + PENTA[step] + (transpose || 0);
    return 440 * Math.pow(2, (midi - 69) / 12);
  }

  function noteName(i) {
    return NOTE_NAMES[((i % 5) + 5) % 5] + (4 + Math.floor(i / 5));
  }

  function midiHz(m, transpose) {
    return 440 * Math.pow(2, (m + (transpose || 0) - 69) / 12);
  }

  function silence(sec, sr) {
    return new Float32Array(Math.max(1, Math.round(sec * sr)));
  }

  function mixInto(out, sig, atSec, sr, gain) {
    const g = gain === undefined ? 1 : gain;
    const i0 = Math.round(atSec * sr);
    const n = Math.min(sig.length, out.length - i0);
    for (let i = 0; i < n; i++) out[i0 + i] += sig[i] * g;
  }

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

  /** Two one-pole stages: a softer, warmer roll-off. */
  function warm(x, fc, sr) {
    return lowpass(lowpass(x, fc, sr), fc, sr);
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

  /** Remove offset, set peak, fade the end, trim trailing silence. */
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

  /** Soft glassy bell / celesta tone. */
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

  function sequence(events, totalSec, sr) {
    const out = silence(totalSec, sr);
    for (const e of events) mixInto(out, e[1], e[0], sr, e[2]);
    return out;
  }

  // ----------------------------------------------------------- the sounds

  function place(p, g, variant, sr) {
    const ratio = [1, 1 + p.variety / 100, 1 - p.variety / 100][variant % 3];
    const f = p.pitch * ratio;
    const tau = p.decay / 1000;
    const dur = tau * 3.6 + 0.03;
    const n = Math.round(dur * sr);
    const rng = rngFor(101 + variant);
    let x = new Float32Array(n);
    const click = new Float32Array(n);
    let phase = 0;
    for (let i = 0; i < n; i++) {
      const t = i / sr;
      phase += (2 * Math.PI * f * (1 + 0.25 * Math.exp(-t / 0.006))) / sr;
      x[i] =
        Math.sin(phase) * Math.exp(-t / tau) +
        0.35 * Math.sin(3.95 * phase) * Math.exp(-t / (tau * 0.4)) +
        0.12 * Math.sin(9.1 * phase) * Math.exp(-t / (tau * 0.18));
      click[i] = gauss(rng) * Math.exp(-t / 0.0025) * p.click;
    }
    const c = lowpass(click, 2500, sr);
    for (let i = 0; i < n; i++) x[i] += c[i];
    x = lowpass(x, p.tone * g.brightness, sr);
    const att = Math.round(0.0015 * sr);
    for (let i = 0; i < att; i++) x[i] *= i / att;
    x = reverb(x, { sr, wet: p.reverb, size: g.room, tail: 0.6 });
    return finish(x, p.volume, sr);
  }

  function pickup(p, g, sr) {
    const tau = p.decay / 1000;
    const x = silence(tau * 6, sr);
    for (let i = 0; i < x.length; i++) {
      x[i] = Math.sin((2 * Math.PI * p.pitch * i) / sr) * Math.exp(-i / sr / tau);
    }
    return finish(x, p.volume, sr);
  }

  function invalid(p, g, sr) {
    const tau = p.decay / 1000;
    let x = silence(tau * 3.5, sr);
    let phase = 0;
    for (let i = 0; i < x.length; i++) {
      const t = i / sr;
      phase += (2 * Math.PI * p.pitch * (1 - 0.3 * t)) / sr;
      x[i] = Math.sin(phase) * Math.exp(-t / tau);
    }
    x = lowpass(x, 900, sr);
    return finish(x, p.volume, sr);
  }

  function clear(p, g, level, sr) {
    const i = p.startNote + (level - 1) * p.stepPerCombo;
    const tr = g.transpose;
    const notes = [penta(i, tr), penta(i + 2, tr), penta(i + 4, tr)];
    const gap = p.noteGap / 1000;
    const events = [[0, bell(notes[0] / 2, p.ring * 0.8, 0.3, sr), p.body]];
    notes.forEach(function (f, k) {
      events.push([k * gap, bell(f, p.ring, p.brightness * g.brightness, sr), 1]);
    });
    let x = sequence(events, p.ring + gap * 3 + 0.1, sr);
    x = reverb(x, { sr, wet: p.reverb, size: g.room, tail: 1.6 });
    return finish(x, p.volume, sr);
  }

  function sweep(p, g, sr) {
    const rng = rngFor(202);
    const dur = p.length + 0.08;
    const noise = silence(dur, sr);
    for (let i = 0; i < noise.length; i++) noise[i] = gauss(rng);
    // Steep (4-pole) top edge so the whoosh stays soft, not hissy.
    const hi = warm(warm(noise, p.high * g.brightness, sr), p.high * g.brightness, sr);
    const lo = warm(noise, p.low, sr);
    let x = new Float32Array(noise.length);
    for (let i = 0; i < x.length; i++) {
      const t = i / sr;
      const s = Math.sin(Math.PI * Math.min(1, t / p.length));
      x[i] = (hi[i] - lo[i]) * s * s;
    }
    x = reverb(x, { sr, wet: p.reverb, size: g.room, tail: 0.8 });
    return finish(x, p.volume, sr);
  }

  function sparkle(p, g, sr) {
    const gap = p.gap / 1000;
    const events = [];
    for (let k = 0; k < p.notes; k++) {
      const f = penta(12 + (k % 5) + Math.floor(k / 5) * 2, g.transpose);
      events.push([k * gap, bell(f, p.ring, p.brightness * g.brightness, sr), 0.6]);
    }
    let x = sequence(events, p.notes * gap + p.ring + 0.05, sr);
    x = reverb(x, { sr, wet: p.reverb, size: g.room, tail: 1.4 });
    return finish(x, p.volume, sr);
  }

  function perfect(p, g, sr) {
    const gap = p.gap / 1000;
    const tr = g.transpose;
    const b = g.brightness;
    const events = [];
    for (let k = 0; k < p.runNotes; k++) {
      events.push([k * gap, bell(penta(5 + k, tr), 0.9, b, sr), 0.7]);
    }
    const at = p.runNotes * gap + 0.03;
    [10, 12, 13, 14].forEach(function (n) {
      events.push([at, bell(penta(n, tr), p.chordRing, b, sr), 0.8]);
    });
    let x = sequence(events, at + p.chordRing + 0.1, sr);
    x = reverb(x, { sr, wet: p.reverb, size: g.room, tail: 2.2 });
    return finish(x, p.volume, sr);
  }

  function gameover(p, g, sr) {
    const gap = p.gap / 1000;
    const tr = g.transpose;
    const top = p.startNote;
    const events = [top, top - 2, top - 4].map(function (n, k) {
      return [k * gap, bell(penta(n, tr), p.ring, 0.4, sr), 1];
    });
    let x = sequence(events, gap * 2 + p.ring + 0.1, sr);
    x = warm(x, p.warmth * g.brightness, sr);
    x = reverb(x, { sr, wet: p.reverb, size: g.room, tail: 2.2 });
    return finish(x, p.volume, sr);
  }

  function revive(p, g, sr) {
    const gap = p.gap / 1000;
    const events = [];
    for (let k = 0; k < p.notes; k++) {
      events.push([
        k * gap,
        bell(penta(5 + k * p.step, g.transpose), p.ring, g.brightness, sr),
        0.7,
      ]);
    }
    let x = sequence(events, p.notes * gap + p.ring + 0.1, sr);
    x = reverb(x, { sr, wet: p.reverb, size: g.room, tail: 1.8 });
    return finish(x, p.volume, sr);
  }

  function coin(p, g, sr) {
    const gap = p.gap / 1000;
    const br = p.brightness * g.brightness;
    let x = sequence(
      [
        [0, bell(penta(p.note1, g.transpose), p.ring * 0.75, br, sr), 1],
        [gap, bell(penta(p.note2, g.transpose), p.ring, br, sr), 1],
      ],
      gap + p.ring + 0.05,
      sr
    );
    x = reverb(x, { sr, wet: p.reverb, size: g.room, tail: 1.0 });
    return finish(x, p.volume, sr);
  }

  function levelup(p, g, sr) {
    const gap = p.gap / 1000;
    const tr = g.transpose;
    const b = g.brightness;
    const events = [5, 7, 8, 10].map(function (n, k) {
      return [k * gap, bell(penta(n, tr), p.ring, b, sr), 1];
    });
    const at = 4 * gap + 0.04;
    [10, 12, 13].forEach(function (n) {
      events.push([at, bell(penta(n, tr), p.ring * 1.5, b, sr), 0.6]);
    });
    let x = sequence(events, at + p.ring * 1.5 + 0.1, sr);
    x = reverb(x, { sr, wet: p.reverb, size: g.room, tail: 1.8 });
    return finish(x, p.volume, sr);
  }

  function tap(p, g, sr) {
    const tau = p.decay / 1000;
    const x = silence(tau * 4, sr);
    let phase = 0;
    for (let i = 0; i < x.length; i++) {
      const t = i / sr;
      const f = p.pitchEnd + (p.pitchStart - p.pitchEnd) * Math.exp(-t / (tau * 0.55));
      phase += (2 * Math.PI * f) / sr;
      x[i] = Math.sin(phase) * Math.exp(-t / tau);
    }
    return finish(x, p.volume, sr);
  }

  const PROGRESSIONS = [
    {
      name: 'Gentle home (C, Am, F, G)',
      chords: [
        [48, 55, 59, 62, 64],
        [45, 52, 55, 59, 60],
        [41, 48, 52, 55, 57],
        [43, 50, 52, 57, 60],
      ],
    },
    {
      name: 'Floating (F, G, Em, Am)',
      chords: [
        [41, 48, 52, 55, 57],
        [43, 50, 55, 57, 59],
        [40, 47, 50, 55, 59],
        [45, 52, 55, 59, 60],
      ],
    },
    {
      name: 'Still water (C, F, C, F)',
      chords: [
        [48, 55, 59, 62, 64],
        [41, 48, 52, 55, 57],
        [48, 55, 60, 62, 67],
        [41, 48, 55, 57, 60],
      ],
    },
  ];

  function music(p, g, sr) {
    const tr = g.transpose;
    const prog = PROGRESSIONS[p.progression] || PROGRESSIONS[0];
    const bar = p.chordSeconds;
    const length = bar * prog.chords.length;
    const tail = 8;
    const out = silence(length + tail, sr);
    const attack = Math.min(2.2, bar * 0.3);
    const release = Math.min(2.6, bar * 0.35);
    prog.chords.forEach(function (notes, ci) {
      notes.forEach(function (m) {
        const f = midiHz(m, tr);
        const dur = bar + 2;
        const n = Math.round(dur * sr);
        const sig = new Float32Array(n);
        [-0.0018, 0, 0.0021].forEach(function (d) {
          const w = (2 * Math.PI * f * (1 + d)) / sr;
          for (let i = 0; i < n; i++) {
            sig[i] += Math.sin(w * i) + 0.18 * Math.sin(2 * w * i);
          }
        });
        for (let i = 0; i < n; i++) {
          const t = i / sr;
          const env = Math.min(1, t / attack) * Math.max(0, Math.min(1, (dur - t) / release));
          const trem = 1 + 0.06 * Math.sin(2 * Math.PI * 0.17 * t + f);
          sig[i] *= (env * trem) / 3;
        }
        mixInto(out, sig, ci * bar, sr, p.padVolume);
      });
    });
    const rng = rngFor(p.seed);
    let t = 1;
    while (p.bellEvery > 0 && t < length - 1) {
      const f = penta(5 + Math.floor(rng() * 8), tr);
      mixInto(out, bell(f, 2.5, 0.5, sr), t, sr, p.bellVolume);
      t += p.bellEvery * [0.67, 1, 1.33][Math.floor(rng() * 3)];
    }
    let x = lowpass(out, p.brightness * g.brightness, sr);
    x = reverb(x, { sr, wet: p.reverb, size: 0.9, damp: 0.5, tail: 4 });
    // Fold the tail back onto the start so the loop has no seam.
    const L = Math.round(length * sr);
    const loop = x.slice(0, L);
    for (let i = L; i < x.length && i - L < L; i++) loop[i - L] += x[i];
    let mean = 0;
    let max = 1e-9;
    for (let i = 0; i < L; i++) mean += loop[i];
    mean /= L;
    for (let i = 0; i < L; i++) {
      loop[i] -= mean;
      max = Math.max(max, Math.abs(loop[i]));
    }
    for (let i = 0; i < L; i++) loop[i] *= p.volume / max;
    return loop;
  }

  // -------------------------------------------- catalogue and parameters

  /*
   * Each sound: what it is, when the game plays it, the files it makes and
   * the knobs you can turn (label, range, unit). `gameVolume` is the extra
   * multiplier the game applies when playing it (written to mix.json).
   */
  const CATALOGUE = [
    {
      key: 'place',
      name: 'Block lands',
      group: 'Gameplay',
      when: 'Every time a block is placed on the board. One of three slightly different pitches is picked at random.',
      files: ['place_0', 'place_1', 'place_2'],
      params: {
        pitch: [330, 180, 620, 5, 'Hz', 'Tone'],
        variety: [4, 0, 12, 0.5, '%', 'Pitch variety'],
        decay: [45, 15, 140, 1, 'ms', 'Length'],
        click: [0.25, 0, 1, 0.05, '', 'Click'],
        tone: [4200, 1200, 9000, 100, 'Hz', 'Brightness'],
        reverb: [0.12, 0, 0.6, 0.01, '', 'Echo'],
        volume: [0.55, 0.1, 0.95, 0.01, '', 'Loudness'],
        gameVolume: [1, 0, 1, 0.05, '', 'In-game volume'],
      },
    },
    {
      key: 'pickup',
      name: 'Pick up a piece',
      group: 'Gameplay',
      when: 'When your finger touches a piece in the tray. Also the tick of the Daily Spin wheel.',
      files: ['pickup'],
      params: {
        pitch: [1400, 400, 3200, 10, 'Hz', 'Tone'],
        decay: [8, 2, 40, 1, 'ms', 'Length'],
        volume: [0.18, 0.05, 0.8, 0.01, '', 'Loudness'],
        gameVolume: [0.5, 0, 1, 0.05, '', 'In-game volume'],
      },
    },
    {
      key: 'invalid',
      name: "Doesn't fit",
      group: 'Gameplay',
      when: "When you let go of a piece over the board where it doesn't fit.",
      files: ['invalid'],
      params: {
        pitch: [150, 60, 420, 5, 'Hz', 'Tone'],
        decay: [40, 10, 160, 1, 'ms', 'Length'],
        volume: [0.35, 0.05, 0.9, 0.01, '', 'Loudness'],
        gameVolume: [0.6, 0, 1, 0.05, '', 'In-game volume'],
      },
    },
    {
      key: 'clear',
      name: 'Line clear chime',
      group: 'Clears',
      when: 'When one or more lines clear. Level 1 is the first clear; each combo step plays the next level up (8 levels).',
      files: ['clear_1', 'clear_2', 'clear_3', 'clear_4', 'clear_5', 'clear_6', 'clear_7', 'clear_8'],
      levels: 8,
      params: {
        startNote: [5, 0, 10, 1, 'note', 'Starting note'],
        stepPerCombo: [1, 1, 3, 1, 'steps', 'Climb per combo'],
        noteGap: [55, 15, 160, 1, 'ms', 'Note spacing'],
        ring: [1.3, 0.3, 3, 0.05, 's', 'Ring length'],
        brightness: [1, 0.2, 2, 0.05, '×', 'Brightness'],
        body: [0.25, 0, 0.8, 0.01, '', 'Low body note'],
        reverb: [0.3, 0, 0.7, 0.01, '', 'Echo'],
        volume: [0.8, 0.1, 0.95, 0.01, '', 'Loudness'],
        gameVolume: [1, 0, 1, 0.05, '', 'In-game volume'],
      },
    },
    {
      key: 'sweep',
      name: 'Light sweep whoosh',
      group: 'Clears',
      when: 'With every line clear, following the band of light along the cleared line.',
      files: ['sweep'],
      params: {
        low: [450, 80, 1500, 10, 'Hz', 'Low edge'],
        high: [2600, 800, 9000, 50, 'Hz', 'High edge'],
        length: [0.42, 0.12, 1.2, 0.01, 's', 'Length'],
        reverb: [0.2, 0, 0.6, 0.01, '', 'Echo'],
        volume: [0.32, 0.05, 0.9, 0.01, '', 'Loudness'],
        gameVolume: [0.7, 0, 1, 0.05, '', 'In-game volume'],
      },
    },
    {
      key: 'sparkle',
      name: 'Multi-line sparkle',
      group: 'Clears',
      when: 'Added on top when two or more lines clear with one block.',
      files: ['sparkle'],
      params: {
        notes: [7, 3, 14, 1, 'notes', 'Notes'],
        gap: [32, 12, 90, 1, 'ms', 'Note spacing'],
        ring: [0.7, 0.2, 2, 0.05, 's', 'Ring length'],
        brightness: [1.4, 0.2, 2.5, 0.05, '×', 'Brightness'],
        reverb: [0.35, 0, 0.7, 0.01, '', 'Echo'],
        volume: [0.45, 0.05, 0.9, 0.01, '', 'Loudness'],
        gameVolume: [0.8, 0, 1, 0.05, '', 'In-game volume'],
      },
    },
    {
      key: 'perfect',
      name: 'Perfect clear',
      group: 'Big moments',
      when: 'When the whole board is emptied, and when a Journey level is completed.',
      files: ['perfect'],
      params: {
        runNotes: [10, 4, 16, 1, 'notes', 'Run length'],
        gap: [45, 20, 120, 1, 'ms', 'Note spacing'],
        chordRing: [2.2, 0.6, 4, 0.05, 's', 'Final chord length'],
        reverb: [0.35, 0, 0.7, 0.01, '', 'Echo'],
        volume: [0.85, 0.1, 0.95, 0.01, '', 'Loudness'],
        gameVolume: [1, 0, 1, 0.05, '', 'In-game volume'],
      },
    },
    {
      key: 'gameover',
      name: 'No more moves',
      group: 'Big moments',
      when: 'The moment none of your pieces fit, as the board fades to grey.',
      files: ['gameover'],
      params: {
        startNote: [9, 4, 12, 1, 'note', 'First note'],
        gap: [240, 80, 600, 5, 'ms', 'Note spacing'],
        ring: [1.8, 0.5, 4, 0.05, 's', 'Ring length'],
        warmth: [2200, 600, 8000, 50, 'Hz', 'Brightness'],
        reverb: [0.4, 0, 0.8, 0.01, '', 'Echo'],
        volume: [0.55, 0.1, 0.95, 0.01, '', 'Loudness'],
        gameVolume: [1, 0, 1, 0.05, '', 'In-game volume'],
      },
    },
    {
      key: 'revive',
      name: 'Revive',
      group: 'Big moments',
      when: 'After watching the revive ad, as the fullest rows clear and play continues.',
      files: ['revive'],
      params: {
        notes: [5, 2, 10, 1, 'notes', 'Notes'],
        step: [2, 1, 3, 1, 'steps', 'Step between notes'],
        gap: [50, 20, 160, 1, 'ms', 'Note spacing'],
        ring: [1, 0.3, 3, 0.05, 's', 'Ring length'],
        reverb: [0.35, 0, 0.7, 0.01, '', 'Echo'],
        volume: [0.7, 0.1, 0.95, 0.01, '', 'Loudness'],
        gameVolume: [1, 0, 1, 0.05, '', 'In-game volume'],
      },
    },
    {
      key: 'coin',
      name: 'Coins',
      group: 'Rewards',
      when: 'Small rewards: a daily goal done, a gem collected, coins doubled, free coins, a spin prize under 100.',
      files: ['coin'],
      params: {
        note1: [13, 8, 18, 1, 'note', 'First note'],
        note2: [15, 8, 20, 1, 'note', 'Second note'],
        gap: [70, 20, 200, 1, 'ms', 'Gap'],
        ring: [0.8, 0.2, 2, 0.05, 's', 'Ring length'],
        brightness: [1.3, 0.2, 2.5, 0.05, '×', 'Brightness'],
        reverb: [0.2, 0, 0.7, 0.01, '', 'Echo'],
        volume: [0.5, 0.1, 0.95, 0.01, '', 'Loudness'],
        gameVolume: [0.8, 0, 1, 0.05, '', 'In-game volume'],
      },
    },
    {
      key: 'levelup',
      name: 'Level up / big reward',
      group: 'Rewards',
      when: 'Big rewards: player level up, Journey level done, daily reward claimed, theme bought, spin prize of 100+.',
      files: ['levelup'],
      params: {
        gap: [80, 30, 200, 1, 'ms', 'Note spacing'],
        ring: [1.2, 0.4, 3, 0.05, 's', 'Ring length'],
        reverb: [0.3, 0, 0.7, 0.01, '', 'Echo'],
        volume: [0.75, 0.1, 0.95, 0.01, '', 'Loudness'],
        gameVolume: [1, 0, 1, 0.05, '', 'In-game volume'],
      },
    },
    {
      key: 'tap',
      name: 'Button tap',
      group: 'Menus',
      when: 'Every button or icon press.',
      files: ['tap'],
      params: {
        pitchStart: [620, 200, 1600, 10, 'Hz', 'Start tone'],
        pitchEnd: [400, 120, 1200, 10, 'Hz', 'End tone'],
        decay: [18, 5, 60, 1, 'ms', 'Length'],
        volume: [0.3, 0.05, 0.9, 0.01, '', 'Loudness'],
        gameVolume: [0.7, 0, 1, 0.05, '', 'In-game volume'],
      },
    },
    {
      key: 'music',
      name: 'Background music',
      group: 'Music',
      when: 'Loops the whole time the app is open (if Music is on). Pauses in the background.',
      files: ['music_loop'],
      sampleRate: MUSIC_SR,
      params: {
        progression: [0, 0, 2, 1, 'choice', 'Chord progression'],
        chordSeconds: [8, 4, 14, 0.5, 's', 'Seconds per chord'],
        padVolume: [0.16, 0, 0.4, 0.01, '', 'Pad level'],
        bellEvery: [3, 0, 8, 0.25, 's', 'Bell every (0 = none)'],
        bellVolume: [0.22, 0, 0.6, 0.01, '', 'Bell level'],
        brightness: [3000, 800, 8000, 50, 'Hz', 'Brightness'],
        reverb: [0.45, 0, 0.85, 0.01, '', 'Echo'],
        seed: [11, 1, 99, 1, '', 'Bell pattern'],
        volume: [0.5, 0.1, 0.9, 0.01, '', 'Loudness'],
        gameVolume: [0.35, 0, 1, 0.05, '', 'In-game volume'],
      },
    },
  ];

  const GLOBAL_PARAMS = {
    transpose: [0, -7, 7, 1, 'semitones', 'Key (all melodies)'],
    brightness: [1, 0.5, 1.6, 0.05, '×', 'Overall brightness'],
    room: [0.84, 0.6, 0.95, 0.01, '', 'Room size (echo length)'],
  };

  function defaults() {
    const out = { version: 1, global: {}, sounds: {} };
    for (const k in GLOBAL_PARAMS) out.global[k] = GLOBAL_PARAMS[k][0];
    for (const s of CATALOGUE) {
      out.sounds[s.key] = {};
      for (const k in s.params) out.sounds[s.key][k] = s.params[k][0];
    }
    return out;
  }

  /** Fills any missing values from the defaults and clamps to the ranges. */
  function normalize(settings) {
    const d = defaults();
    const s = settings || {};
    for (const k in GLOBAL_PARAMS) {
      const r = GLOBAL_PARAMS[k];
      const v = s.global && typeof s.global[k] === 'number' ? s.global[k] : r[0];
      d.global[k] = Math.min(r[2], Math.max(r[1], v));
    }
    for (const snd of CATALOGUE) {
      for (const k in snd.params) {
        const r = snd.params[k];
        const src = s.sounds && s.sounds[snd.key];
        const v = src && typeof src[k] === 'number' ? src[k] : r[0];
        d.sounds[snd.key][k] = Math.min(r[2], Math.max(r[1], v));
      }
    }
    return d;
  }

  /**
   * Renders one file of one sound. `fileIndex` picks the variant (place) or
   * level (clear). Returns { sampleRate, samples }.
   */
  function render(key, settings, fileIndex) {
    const s = normalize(settings);
    const g = s.global;
    const p = s.sounds[key];
    const i = fileIndex || 0;
    const sr = key === 'music' ? MUSIC_SR : SR;
    const fns = {
      place: function () { return place(p, g, i, sr); },
      pickup: function () { return pickup(p, g, sr); },
      invalid: function () { return invalid(p, g, sr); },
      clear: function () { return clear(p, g, i + 1, sr); },
      sweep: function () { return sweep(p, g, sr); },
      sparkle: function () { return sparkle(p, g, sr); },
      perfect: function () { return perfect(p, g, sr); },
      gameover: function () { return gameover(p, g, sr); },
      revive: function () { return revive(p, g, sr); },
      coin: function () { return coin(p, g, sr); },
      levelup: function () { return levelup(p, g, sr); },
      tap: function () { return tap(p, g, sr); },
      music: function () { return music(p, g, sr); },
    };
    return { sampleRate: sr, samples: fns[key]() };
  }

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

  /** In-game volume multipliers, keyed by file name (written as mix.json). */
  function mix(settings) {
    const s = normalize(settings);
    const out = {};
    for (const snd of CATALOGUE) {
      for (const f of snd.files) out[f] = s.sounds[snd.key].gameVolume;
    }
    return out;
  }

  return {
    CATALOGUE: CATALOGUE,
    GLOBAL_PARAMS: GLOBAL_PARAMS,
    PROGRESSIONS: PROGRESSIONS,
    defaults: defaults,
    normalize: normalize,
    render: render,
    wav: wav,
    mix: mix,
    noteName: noteName,
  };
});
