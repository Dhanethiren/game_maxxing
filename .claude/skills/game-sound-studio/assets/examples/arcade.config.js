/*
 * Example sound config: a bright arcade / platformer game with retro
 * (chiptune-style) voices: jump, pickup, power-up, hit, explosion, laser,
 * game over and a tempo-based music loop. Square and triangle waves, softened
 * with low-pass filters so they stay pleasant on phone speakers.
 *
 * All patterns here are original; don't copy famous game jingles note for note.
 */
(function (root, factory) {
  if (typeof module === 'object' && module.exports) module.exports = factory;
  else root.SoundConfig = factory;
})(typeof self !== 'undefined' ? self : this, function (core) {
  'use strict';
  const { blip, noiseHit, warm, lowpass, finish, sequence, silence, mixInto, reverb } = core;

  // A retro note: square or triangle, softened so it never buzzes.
  function chip(f, dur, shape, sr, soft) {
    const y = blip({ freq: f, dur: dur, decay: dur * 0.6, shape: shape || 'square', attack: 0.003, sr: sr });
    return warm(y, soft || 3500, sr);
  }

  const PATTERNS = ['Up and over', 'Bounce', 'Run'];
  const ARPS = [[0, 2, 4, 7], [0, 4, 2, 4], [0, 2, 4, 2]];

  return {
    title: 'Pixel Dash',
    subtitle: 'Retro sounds for the game: tweak them until they feel snappy.',
    outDir: '../../assets/audio',
    // Optional page colour (light theme / dark theme).
    theme: { accent: '#c2364d', accentDark: '#ff8fa0' },
    scale: { root: 60, steps: core.SCALES.major },
    global: {
      transpose: [0, -7, 7, 1, 'semitones', 'Key (all melodies)'],
      softness: [3500, 1500, 8000, 100, 'Hz', 'Retro softness (lower = rounder)'],
    },
    preview: ['pickup', 0],
    sounds: [
      {
        key: 'jump',
        name: 'Jump',
        group: 'Player',
        when: 'The player jumps. Three variants are picked at random.',
        files: ['jump_0', 'jump_1', 'jump_2'],
        params: {
          from: [260, 120, 600, 5, 'Hz', 'Start pitch'],
          to: [720, 300, 1600, 10, 'Hz', 'End pitch'],
          length: [0.16, 0.06, 0.4, 0.01, 's', 'Length'],
          variety: [5, 0, 12, 0.5, '%', 'Pitch variety'],
          volume: [0.45, 0.05, 0.9, 0.01, '', 'Loudness'],
          gameVolume: [0.7, 0, 1, 0.05, '', 'In-game volume'],
        },
        render(p, g, x) {
          const r = [1, 1 + p.variety / 100, 1 - p.variety / 100][x.index % 3];
          const y = blip({ freq: p.from * r, freqEnd: p.to * r, glide: p.length / 3, dur: p.length, decay: p.length * 0.7, shape: 'square', sr: x.sr });
          return finish(warm(y, g.softness, x.sr), p.volume, x.sr);
        },
      },
      {
        key: 'pickup',
        name: 'Pickup',
        group: 'Player',
        when: 'A coin or gem is collected. Rapid pickups step up the scale (5 levels).',
        files: ['pickup_1', 'pickup_2', 'pickup_3', 'pickup_4', 'pickup_5'],
        chipLabel: '#{n}',
        chipGroupLabel: 'Pickup in a row',
        params: {
          note: [7, 0, 10, 1, 'note', 'First note'],
          leap: [3, 1, 5, 1, 'count', 'Leap (scale steps)'],
          gap: [55, 25, 120, 1, 'ms', 'Gap'],
          length: [0.12, 0.05, 0.3, 0.01, 's', 'Note length'],
          volume: [0.45, 0.05, 0.9, 0.01, '', 'Loudness'],
          gameVolume: [0.75, 0, 1, 0.05, '', 'In-game volume'],
        },
        render(p, g, x) {
          const n = p.note + x.index;
          const gap = p.gap / 1000;
          const y = sequence([
            [0, chip(x.hz(n), p.length * 0.6, 'square', x.sr, g.softness), 0.8],
            [gap, chip(x.hz(n + p.leap), p.length, 'square', x.sr, g.softness), 1],
          ], gap + p.length, x.sr);
          return finish(y, p.volume, x.sr);
        },
      },
      {
        key: 'powerup',
        name: 'Power-up',
        group: 'Player',
        when: 'A power-up is collected.',
        files: ['powerup'],
        params: {
          notes: [8, 4, 16, 1, 'count', 'Notes'],
          gap: [45, 20, 100, 1, 'ms', 'Note spacing'],
          volume: [0.5, 0.05, 0.9, 0.01, '', 'Loudness'],
          gameVolume: [0.9, 0, 1, 0.05, '', 'In-game volume'],
        },
        render(p, g, x) {
          const gap = p.gap / 1000;
          const ev = [];
          for (let k = 0; k < p.notes; k++) ev.push([k * gap, chip(x.hz(k), 0.09, k % 2 ? 'triangle' : 'square', x.sr, g.softness), 0.9]);
          return finish(sequence(ev, p.notes * gap + 0.1, x.sr), p.volume, x.sr);
        },
      },
      {
        key: 'hit',
        name: 'Hit',
        group: 'Combat',
        when: 'The player or an enemy takes a hit.',
        files: ['hit'],
        params: {
          thump: [140, 60, 300, 5, 'Hz', 'Thump pitch'],
          crunch: [0.6, 0, 1, 0.05, '', 'Crunch'],
          length: [0.12, 0.05, 0.3, 0.01, 's', 'Length'],
          volume: [0.6, 0.05, 0.9, 0.01, '', 'Loudness'],
          gameVolume: [0.8, 0, 1, 0.05, '', 'In-game volume'],
        },
        render(p, g, x) {
          const sr = x.sr;
          const out = silence(p.length * 2, sr);
          mixInto(out, blip({ freq: p.thump * 2, freqEnd: p.thump, glide: 0.02, dur: p.length * 2, decay: p.length / 2, shape: 'triangle', sr }), 0, sr, 1);
          mixInto(out, noiseHit({ dur: p.length, decay: p.length / 4, tone: g.softness, sr, seed: 5 }), 0, sr, p.crunch);
          return finish(out, p.volume, sr);
        },
      },
      {
        key: 'explosion',
        name: 'Explosion',
        group: 'Combat',
        when: 'An enemy or block is destroyed.',
        files: ['explosion'],
        params: {
          length: [0.7, 0.2, 2, 0.05, 's', 'Length'],
          start: [3000, 800, 8000, 100, 'Hz', 'Start brightness'],
          end: [200, 60, 1000, 10, 'Hz', 'End brightness'],
          volume: [0.6, 0.05, 0.9, 0.01, '', 'Loudness'],
          gameVolume: [0.8, 0, 1, 0.05, '', 'In-game volume'],
        },
        // Noise through a low-pass that closes over time: bright crack to rumble.
        render(p, g, x) {
          const sr = x.sr;
          const n = core.noise(p.length, sr, 12);
          const y = new Float32Array(n.length);
          let s = 0;
          for (let i = 0; i < n.length; i++) {
            const t = i / sr / p.length;
            const fc = p.end + (p.start - p.end) * Math.exp(-t * 5);
            s += (1 - Math.exp((-2 * Math.PI * fc) / sr)) * (n[i] - s);
            y[i] = s * Math.exp(-t * 4);
          }
          return finish(core.attack(lowpass(y, 6000, sr), 0.002, sr), p.volume, sr);
        },
      },
      {
        key: 'laser',
        name: 'Laser',
        group: 'Combat',
        when: 'The player shoots.',
        files: ['laser'],
        params: {
          from: [1600, 600, 3000, 10, 'Hz', 'Start pitch'],
          to: [220, 80, 800, 10, 'Hz', 'End pitch'],
          length: [0.14, 0.05, 0.4, 0.01, 's', 'Length'],
          volume: [0.35, 0.05, 0.9, 0.01, '', 'Loudness'],
          gameVolume: [0.6, 0, 1, 0.05, '', 'In-game volume'],
        },
        render(p, g, x) {
          const y = blip({ freq: p.from, freqEnd: p.to, glide: p.length / 4, dur: p.length, decay: p.length / 2, shape: 'saw', sr: x.sr });
          return finish(warm(y, g.softness, x.sr), p.volume, x.sr);
        },
      },
      {
        key: 'gameover',
        name: 'Game over',
        group: 'Moments',
        when: 'The run ends.',
        files: ['gameover'],
        params: {
          gap: [180, 80, 400, 5, 'ms', 'Note spacing'],
          echo: [0.25, 0, 0.6, 0.01, '', 'Echo'],
          volume: [0.55, 0.05, 0.9, 0.01, '', 'Loudness'],
          gameVolume: [1, 0, 1, 0.05, '', 'In-game volume'],
        },
        render(p, g, x) {
          const gap = p.gap / 1000;
          const ev = [4, 3, 2, 0].map(function (n, k) {
            return [k * gap, chip(x.hz(n), k === 3 ? 0.6 : 0.2, 'triangle', x.sr, g.softness), 1];
          });
          const y = reverb(sequence(ev, gap * 3 + 0.7, x.sr), { sr: x.sr, wet: p.echo, size: 0.8, tail: 1 });
          return finish(y, p.volume, x.sr);
        },
      },
      {
        key: 'music',
        name: 'Level music',
        group: 'Music',
        when: 'Loops during play.',
        files: ['music_level'],
        loop: true,
        sampleRate: 22050,
        params: {
          tempo: [132, 90, 170, 1, 'bpm', 'Tempo'],
          pattern: [0, 0, 2, 1, 'choice', 'Arpeggio pattern', PATTERNS],
          lead: [0.22, 0, 0.5, 0.01, '', 'Arpeggio level'],
          bass: [0.35, 0, 0.6, 0.01, '', 'Bass level'],
          drums: [0.12, 0, 0.4, 0.01, '', 'Hi-hat level'],
          volume: [0.6, 0.1, 0.9, 0.01, '', 'Loudness'],
          gameVolume: [0.4, 0, 1, 0.05, '', 'In-game volume'],
        },
        // 4 bars of I-vi-IV-V: triangle bass on the beat, a square arpeggio
        // in 16ths, a noise hi-hat on the off-beats. Rendered past the end and
        // folded so the loop point is seamless.
        render(p, g, x) {
          const sr = x.sr;
          const step = 60 / p.tempo / 4;
          const bars = [0, 5, 3, 4];
          const length = step * 16 * bars.length;
          const out = silence(length + 1, sr);
          const arp = ARPS[Math.round(p.pattern)] || ARPS[0];
          bars.forEach(function (root, b) {
            for (let s = 0; s < 16; s++) {
              const t = (b * 16 + s) * step;
              mixInto(out, chip(x.hz(root + arp[s % 4] + 7), step * 0.9, 'square', sr, g.softness * 0.8), t, sr, p.lead);
              if (s % 4 === 0) mixInto(out, chip(x.hz(root - 7), step * 3.5, 'triangle', sr, 1500), t, sr, p.bass);
              if (s % 4 === 2) mixInto(out, noiseHit({ dur: 0.04, decay: 0.008, low: 5000, high: 9000, sr, seed: 30 + s }), t, sr, p.drums);
            }
          });
          return core.peakNormalize(core.loopFold(out, length, sr), p.volume);
        },
      },
    ],
    scenarios: [
      { name: 'Collect a row of coins', desc: 'Jump, then five pickups in a row', events: [[0, 'jump', 0], [250, 'pickup', 0], [420, 'pickup', 1], [590, 'pickup', 2], [760, 'pickup', 3], [930, 'pickup', 4]] },
      { name: 'Fight', desc: 'Shoot, hit, destroy', events: [[0, 'laser'], [200, 'laser'], [260, 'hit'], [600, 'laser'], [680, 'explosion']] },
      { name: 'Power up', desc: 'Jump into a power-up', events: [[0, 'jump', 1], [300, 'powerup']] },
      { name: 'Lose', desc: 'Hit, then game over', events: [[0, 'hit'], [500, 'gameover']] },
    ],
  };
});
