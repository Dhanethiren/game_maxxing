/*
 * Example sound config: a calm block-puzzle game (the Calm Grid set).
 *
 * Soft wooden "tock" for placing, glassy pentatonic bells that climb with
 * each combo, a filtered-noise whoosh, celebratory runs and a slow pad loop.
 * Copy this next to synth_core.js as sounds.config.js and adapt it.
 *
 * A config is a function of the core (DSP helpers) that returns:
 *   title, scale, sampleRate, outDir, global, sounds[], scenarios[], preview
 * Each sound's render(p, g, x) gets its params `p`, the global params `g`
 * and helpers `x` = { index, sr, hz(degree), midi(note), core, scale }, and
 * returns a Float32Array (mono, -1..1).
 */
(function (root, factory) {
  if (typeof module === 'object' && module.exports) module.exports = factory;
  else root.SoundConfig = factory;
})(typeof self !== 'undefined' ? self : this, function (core) {
  'use strict';
  const { lowpass, warm, reverb, finish, bell, sequence, silence, gauss, rngFor } = core;

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

  const sounds = [
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
      // A wooden/clay "tock": a sine with a tiny pitch drop at the hit, two
      // fast-decaying overtones and a filtered noise click.
      render(p, g, x) {
        const sr = x.sr;
        const variant = x.index;
        const ratio = [1, 1 + p.variety / 100, 1 - p.variety / 100][variant % 3];
        const f = p.pitch * ratio;
        const tau = p.decay / 1000;
        const dur = tau * 3.6 + 0.03;
        const n = Math.round(dur * sr);
        const rng = rngFor(101 + variant);
        let y = new Float32Array(n);
        const click = new Float32Array(n);
        let phase = 0;
        for (let i = 0; i < n; i++) {
          const t = i / sr;
          phase += (2 * Math.PI * f * (1 + 0.25 * Math.exp(-t / 0.006))) / sr;
          y[i] =
            Math.sin(phase) * Math.exp(-t / tau) +
            0.35 * Math.sin(3.95 * phase) * Math.exp(-t / (tau * 0.4)) +
            0.12 * Math.sin(9.1 * phase) * Math.exp(-t / (tau * 0.18));
          click[i] = gauss(rng) * Math.exp(-t / 0.0025) * p.click;
        }
        const c = lowpass(click, 2500, sr);
        for (let i = 0; i < n; i++) y[i] += c[i];
        y = lowpass(y, p.tone * g.brightness, sr);
        const att = Math.round(0.0015 * sr);
        for (let i = 0; i < att; i++) y[i] *= i / att;
        y = reverb(y, { sr, wet: p.reverb, size: g.room, tail: 0.6 });
        return finish(y, p.volume, sr);
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
      render(p, g, x) {
        const sr = x.sr;
        const tau = p.decay / 1000;
        const y = silence(tau * 6, sr);
        for (let i = 0; i < y.length; i++) {
          y[i] = Math.sin((2 * Math.PI * p.pitch * i) / sr) * Math.exp(-i / sr / tau);
        }
        return finish(y, p.volume, sr);
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
      // A soft low bump, deliberately not a buzzer.
      render(p, g, x) {
        const sr = x.sr;
        const tau = p.decay / 1000;
        let y = silence(tau * 3.5, sr);
        let phase = 0;
        for (let i = 0; i < y.length; i++) {
          const t = i / sr;
          phase += (2 * Math.PI * p.pitch * (1 - 0.3 * t)) / sr;
          y[i] = Math.sin(phase) * Math.exp(-t / tau);
        }
        y = lowpass(y, 900, sr);
        return finish(y, p.volume, sr);
      },
    },
    {
      key: 'clear',
      name: 'Line clear chime',
      group: 'Clears',
      when: 'When one or more lines clear. Level 1 is the first clear; each combo step plays the next level up (8 levels).',
      files: ['clear_1', 'clear_2', 'clear_3', 'clear_4', 'clear_5', 'clear_6', 'clear_7', 'clear_8'],
      chipLabel: '×{n}',
      chipGroupLabel: 'Combo level',
      params: {
        startNote: [5, 0, 10, 1, 'note', 'Starting note'],
        stepPerCombo: [1, 1, 3, 1, 'count', 'Climb per combo'],
        noteGap: [55, 15, 160, 1, 'ms', 'Note spacing'],
        ring: [1.3, 0.3, 3, 0.05, 's', 'Ring length'],
        brightness: [1, 0.2, 2, 0.05, '×', 'Brightness'],
        body: [0.25, 0, 0.8, 0.01, '', 'Low body note'],
        reverb: [0.3, 0, 0.7, 0.01, '', 'Echo'],
        volume: [0.8, 0.1, 0.95, 0.01, '', 'Loudness'],
        gameVolume: [1, 0, 1, 0.05, '', 'In-game volume'],
      },
      // Three bell notes (a pentatonic triad), one scale step higher per
      // combo level, over a quiet octave-down body note.
      render(p, g, x) {
        const sr = x.sr;
        const i = p.startNote + x.index * p.stepPerCombo;
        const notes = [x.hz(i), x.hz(i + 2), x.hz(i + 4)];
        const gap = p.noteGap / 1000;
        const events = [[0, bell(notes[0] / 2, p.ring * 0.8, 0.3, sr), p.body]];
        notes.forEach(function (f, k) {
          events.push([k * gap, bell(f, p.ring, p.brightness * g.brightness, sr), 1]);
        });
        let y = sequence(events, p.ring + gap * 3 + 0.1, sr);
        y = reverb(y, { sr, wet: p.reverb, size: g.room, tail: 1.6 });
        return finish(y, p.volume, sr);
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
      // Band-passed noise with a sine-squared swell. The steep 4-pole top
      // edge keeps it soft rather than hissy.
      render(p, g, x) {
        const sr = x.sr;
        const noise = core.noise(p.length + 0.08, sr, 202);
        const hi = warm(warm(noise, p.high * g.brightness, sr), p.high * g.brightness, sr);
        const lo = warm(noise, p.low, sr);
        let y = new Float32Array(noise.length);
        for (let i = 0; i < y.length; i++) {
          const t = i / sr;
          const s = Math.sin(Math.PI * Math.min(1, t / p.length));
          y[i] = (hi[i] - lo[i]) * s * s;
        }
        y = reverb(y, { sr, wet: p.reverb, size: g.room, tail: 0.8 });
        return finish(y, p.volume, sr);
      },
    },
    {
      key: 'sparkle',
      name: 'Multi-line sparkle',
      group: 'Clears',
      when: 'Added on top when two or more lines clear with one block.',
      files: ['sparkle'],
      params: {
        notes: [7, 3, 14, 1, 'count', 'Notes'],
        gap: [32, 12, 90, 1, 'ms', 'Note spacing'],
        ring: [0.7, 0.2, 2, 0.05, 's', 'Ring length'],
        brightness: [1.4, 0.2, 2.5, 0.05, '×', 'Brightness'],
        reverb: [0.35, 0, 0.7, 0.01, '', 'Echo'],
        volume: [0.45, 0.05, 0.9, 0.01, '', 'Loudness'],
        gameVolume: [0.8, 0, 1, 0.05, '', 'In-game volume'],
      },
      render(p, g, x) {
        const sr = x.sr;
        const gap = p.gap / 1000;
        const events = [];
        for (let k = 0; k < p.notes; k++) {
          const f = x.hz(12 + (k % 5) + Math.floor(k / 5) * 2);
          events.push([k * gap, bell(f, p.ring, p.brightness * g.brightness, sr), 0.6]);
        }
        let y = sequence(events, p.notes * gap + p.ring + 0.05, sr);
        y = reverb(y, { sr, wet: p.reverb, size: g.room, tail: 1.4 });
        return finish(y, p.volume, sr);
      },
    },
    {
      key: 'perfect',
      name: 'Perfect clear',
      group: 'Big moments',
      when: 'When the whole board is emptied, and when a level is completed.',
      files: ['perfect'],
      params: {
        runNotes: [10, 4, 16, 1, 'count', 'Run length'],
        gap: [45, 20, 120, 1, 'ms', 'Note spacing'],
        chordRing: [2.2, 0.6, 4, 0.05, 's', 'Final chord length'],
        reverb: [0.35, 0, 0.7, 0.01, '', 'Echo'],
        volume: [0.85, 0.1, 0.95, 0.01, '', 'Loudness'],
        gameVolume: [1, 0, 1, 0.05, '', 'In-game volume'],
      },
      // A run up the scale into a held four-note chord.
      render(p, g, x) {
        const sr = x.sr;
        const gap = p.gap / 1000;
        const b = g.brightness;
        const events = [];
        for (let k = 0; k < p.runNotes; k++) {
          events.push([k * gap, bell(x.hz(5 + k), 0.9, b, sr), 0.7]);
        }
        const at = p.runNotes * gap + 0.03;
        [10, 12, 13, 14].forEach(function (n) {
          events.push([at, bell(x.hz(n), p.chordRing, b, sr), 0.8]);
        });
        let y = sequence(events, at + p.chordRing + 0.1, sr);
        y = reverb(y, { sr, wet: p.reverb, size: g.room, tail: 2.2 });
        return finish(y, p.volume, sr);
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
      // Three descending, low-passed bells: calm, not sad.
      render(p, g, x) {
        const sr = x.sr;
        const gap = p.gap / 1000;
        const top = p.startNote;
        const events = [top, top - 2, top - 4].map(function (n, k) {
          return [k * gap, bell(x.hz(n), p.ring, 0.4, sr), 1];
        });
        let y = sequence(events, gap * 2 + p.ring + 0.1, sr);
        y = warm(y, p.warmth * g.brightness, sr);
        y = reverb(y, { sr, wet: p.reverb, size: g.room, tail: 2.2 });
        return finish(y, p.volume, sr);
      },
    },
    {
      key: 'revive',
      name: 'Revive',
      group: 'Big moments',
      when: 'After watching the revive ad, as the fullest rows clear and play continues.',
      files: ['revive'],
      params: {
        notes: [5, 2, 10, 1, 'count', 'Notes'],
        step: [2, 1, 3, 1, 'count', 'Step between notes'],
        gap: [50, 20, 160, 1, 'ms', 'Note spacing'],
        ring: [1, 0.3, 3, 0.05, 's', 'Ring length'],
        reverb: [0.35, 0, 0.7, 0.01, '', 'Echo'],
        volume: [0.7, 0.1, 0.95, 0.01, '', 'Loudness'],
        gameVolume: [1, 0, 1, 0.05, '', 'In-game volume'],
      },
      render(p, g, x) {
        const sr = x.sr;
        const gap = p.gap / 1000;
        const events = [];
        for (let k = 0; k < p.notes; k++) {
          events.push([k * gap, bell(x.hz(5 + k * p.step), p.ring, g.brightness, sr), 0.7]);
        }
        let y = sequence(events, p.notes * gap + p.ring + 0.1, sr);
        y = reverb(y, { sr, wet: p.reverb, size: g.room, tail: 1.8 });
        return finish(y, p.volume, sr);
      },
    },
    {
      key: 'coin',
      name: 'Coins',
      group: 'Rewards',
      when: 'Small rewards: a daily goal done, a gem collected, coins doubled, free coins, a small spin prize.',
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
      render(p, g, x) {
        const sr = x.sr;
        const gap = p.gap / 1000;
        const br = p.brightness * g.brightness;
        let y = sequence(
          [
            [0, bell(x.hz(p.note1), p.ring * 0.75, br, sr), 1],
            [gap, bell(x.hz(p.note2), p.ring, br, sr), 1],
          ],
          gap + p.ring + 0.05,
          sr
        );
        y = reverb(y, { sr, wet: p.reverb, size: g.room, tail: 1.0 });
        return finish(y, p.volume, sr);
      },
    },
    {
      key: 'levelup',
      name: 'Level up / big reward',
      group: 'Rewards',
      when: 'Big rewards: player level up, level done, daily reward claimed, item bought, a big spin prize.',
      files: ['levelup'],
      params: {
        gap: [80, 30, 200, 1, 'ms', 'Note spacing'],
        ring: [1.2, 0.4, 3, 0.05, 's', 'Ring length'],
        reverb: [0.3, 0, 0.7, 0.01, '', 'Echo'],
        volume: [0.75, 0.1, 0.95, 0.01, '', 'Loudness'],
        gameVolume: [1, 0, 1, 0.05, '', 'In-game volume'],
      },
      // C-E-G-C arpeggio into a chord.
      render(p, g, x) {
        const sr = x.sr;
        const gap = p.gap / 1000;
        const b = g.brightness;
        const events = [5, 7, 8, 10].map(function (n, k) {
          return [k * gap, bell(x.hz(n), p.ring, b, sr), 1];
        });
        const at = 4 * gap + 0.04;
        [10, 12, 13].forEach(function (n) {
          events.push([at, bell(x.hz(n), p.ring * 1.5, b, sr), 0.6]);
        });
        let y = sequence(events, at + p.ring * 1.5 + 0.1, sr);
        y = reverb(y, { sr, wet: p.reverb, size: g.room, tail: 1.8 });
        return finish(y, p.volume, sr);
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
      // A soft "pop": a sine falling from pitchStart to pitchEnd.
      render(p, g, x) {
        const sr = x.sr;
        const tau = p.decay / 1000;
        const y = silence(tau * 4, sr);
        let phase = 0;
        for (let i = 0; i < y.length; i++) {
          const t = i / sr;
          const f = p.pitchEnd + (p.pitchStart - p.pitchEnd) * Math.exp(-t / (tau * 0.55));
          phase += (2 * Math.PI * f) / sr;
          y[i] = Math.sin(phase) * Math.exp(-t / tau);
        }
        return finish(y, p.volume, sr);
      },
    },
    {
      key: 'music',
      name: 'Background music',
      group: 'Music',
      when: 'Loops the whole time the app is open (if Music is on). Pauses in the background.',
      files: ['music_loop'],
      loop: true,
      sampleRate: 22050,
      params: {
        progression: [0, 0, 2, 1, 'choice', 'Chord progression', PROGRESSIONS.map(function (q) { return q.name; })],
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
      // Four soft pad chords with sparse random bells, a long reverb, and
      // the tail folded back onto the start so the loop has no seam.
      render(p, g, x) {
        const sr = x.sr;
        const prog = PROGRESSIONS[Math.round(p.progression)] || PROGRESSIONS[0];
        const bar = p.chordSeconds;
        const length = bar * prog.chords.length;
        const out = silence(length + 8, sr);
        const opts = { attack: Math.min(2.2, bar * 0.3), release: Math.min(2.6, bar * 0.35) };
        prog.chords.forEach(function (notes, ci) {
          notes.forEach(function (m) {
            core.mixInto(out, core.padNote(x.midi(m), bar + 2, sr, opts), ci * bar, sr, p.padVolume);
          });
        });
        const rng = rngFor(p.seed);
        let t = 1;
        while (p.bellEvery > 0 && t < length - 1) {
          const f = x.hz(5 + Math.floor(rng() * 8));
          core.mixInto(out, bell(f, 2.5, 0.5, sr), t, sr, p.bellVolume);
          t += p.bellEvery * [0.67, 1, 1.33][Math.floor(rng() * 3)];
        }
        let y = lowpass(out, p.brightness * g.brightness, sr);
        y = reverb(y, { sr, wet: p.reverb, size: 0.9, damp: 0.5, tail: 4 });
        return core.peakNormalize(core.loopFold(y, length, sr), p.volume);
      },
    },
  ];

  return {
    title: 'Calm Grid',
    subtitle: 'Listen to every sound in the game, move the sliders, and hear the change straight away.',
    // Where render.js writes the files, relative to this config file.
    outDir: '../../assets/sounds',
    sampleRate: 44100,
    // Scale degrees for x.hz(i) and 'note' params: C major pentatonic from C4,
    // so degree 5 is C5. Pentatonic never clashes when sounds overlap.
    scale: { root: 60, steps: core.SCALES.majorPentatonic },
    global: {
      transpose: [0, -7, 7, 1, 'semitones', 'Key (all melodies)'],
      brightness: [1, 0.5, 1.6, 0.05, '×', 'Overall brightness'],
      room: [0.84, 0.6, 0.95, 0.01, '', 'Room size (echo length)'],
    },
    // Played after a "Whole set" slider changes: [key, fileIndex].
    preview: ['clear', 0],
    sounds: sounds,
    // "Try it in context" pads: events are [ms, soundKey, fileIndex].
    scenarios: [
      { name: 'Place three blocks', desc: 'Pick up, drop, three times', events: [[0, 'pickup'], [180, 'place', 0], [620, 'pickup'], [800, 'place', 1], [1240, 'pickup'], [1420, 'place', 2]] },
      {
        name: 'Combo climb ×1 → ×8',
        desc: 'A clear on every move',
        events: (function () {
          const ev = [];
          for (let k = 0; k < 8; k++) {
            const t = k * 1100;
            ev.push([t, 'place', k % 3], [t + 60, 'clear', k], [t + 60, 'sweep']);
          }
          return ev;
        })(),
      },
      { name: 'Two lines at once', desc: 'Chime, whoosh and sparkle', events: [[0, 'place', 0], [60, 'clear', 0], [60, 'sweep'], [60, 'sparkle']] },
      { name: 'Perfect clear', desc: 'The whole board empties', events: [[0, 'place', 1], [60, 'clear', 2], [60, 'sweep'], [60, 'sparkle'], [60, 'perfect']] },
      { name: 'Run out of moves', desc: "Doesn't fit, then no more moves", events: [[0, 'pickup'], [420, 'invalid'], [1150, 'gameover']] },
      { name: 'Revive and carry on', desc: 'After the revive ad', events: [[0, 'revive'], [1700, 'pickup'], [1880, 'place', 0], [2600, 'place', 1], [2660, 'clear', 0], [2660, 'sweep']] },
      { name: 'Rewards', desc: 'Goal done, then a level up', events: [[0, 'coin'], [750, 'coin'], [1700, 'levelup']] },
      { name: 'Menu taps', desc: 'Moving around the menus', events: [[0, 'tap'], [260, 'tap'], [520, 'tap'], [780, 'tap']] },
    ],
  };
});
