# Recipes and core API

Read this while writing `sounds.config.js`. Each recipe below is a complete
sound entry: paste it into the config's `sounds` array, then rename the key
and files and adjust the knobs. Inside a config, `core` is the argument of
the config function. Every recipe here renders and passes `analyze.js`.

The longer recipes live in the example configs:

| Recipe | Where to find it |
|---|---|
| Wooden or clay "tock" | `calm-puzzle.config.js` → `place` |
| Calm pad music loop with sparse bells | `calm-puzzle.config.js` → `music` |
| Tempo-based chiptune loop (bass, arpeggio, hi-hat) | `arcade.config.js` → `music` |
| Explosion (a closing low-pass on noise) | `arcade.config.js` → `explosion` |
| Toggle on/off pair | `app-ui.config.js` → `toggle` |

## Contents

1. The `render(p, g, x)` contract
2. Core API
3. Recipes
   - Touch: soft tap, tick, bubble pop
   - Action: soft thud, jump, laser, card swipe
   - Feedback: gentle error, success, notification
   - Rewards: chime with combo ladder, coin, sparkle run, power-up, level up
   - Moments: whoosh, game over
4. Patterns: variants, levels, layers, loops

## 1. The `render(p, g, x)` contract

| Argument | What it holds |
|---|---|
| `p` | This sound's knob values, already clamped to their ranges |
| `g` | The global knob values (e.g. `g.transpose`, `g.brightness`, `g.room`). Only the ones the config defines exist, so use `(g.brightness \|\| 1)` in shared snippets |
| `x.index` | Which file of `files` is being rendered (the variant or level) |
| `x.sr` | The sample rate (the sound's `sampleRate`, else the config's, else 44100) |
| `x.hz(degree)` | Frequency of a scale degree in the config's scale, with the global transpose applied. With 5 steps from root 60, degree 0 is C4 and 5 is C5 |
| `x.midi(note)` | Frequency of a MIDI note with the transpose applied |
| `x.core` | The same helpers as `core` |

The return value is a `Float32Array`, mono, between −1 and 1. End a
one-shot with `core.finish(y, p.volume, x.sr)`. That removes DC offset, sets
the peak, trims the silent tail and fades the end.

## 2. Core API

| Function | Use |
|---|---|
| `rngFor(seed)` → `() => 0..1` | Seeded random numbers. Use this, never `Math.random` |
| `gauss(rng)`, `noise(sec, sr, seed)` | Normal random value; a white-noise buffer |
| `SCALES.*`, `midiHz(m, tr)`, `midiName(m)`, `scaleHz(i, scale, tr)`, `scaleMidi`, `scaleNoteName` | Pitch helpers. Usually `x.hz` and `x.midi` are enough |
| `silence(sec, sr)` | An empty buffer |
| `mixInto(out, sig, atSec, sr, gain)` | Add a signal into a buffer at a time |
| `sequence([[atSec, sig, gain], ...], totalSec, sr)` | Build a buffer from timed events |
| `lowpass(x, fc, sr)` | Gentle 6 dB/oct low-pass |
| `warm(x, fc, sr)` | Softer 12 dB/oct low-pass |
| `highpass(x, fc, sr)` | 6 dB/oct high-pass |
| `bandpass(x, lo, hi, sr)` | Steep band; good for whooshes |
| `reverb(x, { sr, wet, size, damp, tail })` | Room. `wet` 0–0.6, `size` 0.6–0.95, `tail` in seconds added to the end |
| `attack(x, sec, sr)`, `fadeOut(x, sec, sr)` | Linear fades, in place |
| `finish(x, peak, sr)` | The last step for one-shots |
| `peakNormalize(x, peak)` | DC removal and peak scaling without trimming (for loops) |
| `loopFold(x, loopSec, sr)` | Folds everything past the loop point back onto the start, for a seamless loop |
| `bell(freq, dur, bright, sr)` | Glassy bell or celesta. `bright` from 0 to 2 |
| `blip({ freq, freqEnd, glide, dur, decay, shape, attack, sr })` | One synth note with a pitch glide. `shape` is `sine`, `triangle`, `square` or `saw`. Low-pass `square` and `saw` |
| `pluck(freq, dur, sr, { decay, blend, seed })` | Plucked string (Karplus-Strong). Keep it under ~1.5 kHz |
| `padNote(freq, dur, sr, { attack, release, detune, harmonic2, tremolo })` | A soft pad voice for music beds |
| `noiseHit({ dur, decay, tone \| low+high, seed, sr })` | Filtered noise burst: hits, clicks, paper, hi-hats |
| `wav(samples, sr)` | 16-bit mono WAV bytes (used by `render.js`) |

## 3. Recipes

### Touch

**Soft tap / pop**: every button press.

```js
{
  key: 'tap', name: 'Button tap', group: 'Menus', when: 'Any button press.',
  files: ['tap'],
  params: {
    pitch: [700, 250, 1600, 10, 'Hz', 'Tone'],
    drop: [35, 0, 70, 1, '%', 'Pitch drop'],
    length: [16, 5, 60, 1, 'ms', 'Length'],
    volume: [0.3, 0.05, 0.9, 0.01, '', 'Loudness'],
    gameVolume: [0.6, 0, 1, 0.05, '', 'In-game volume'],
  },
  render(p, g, x) {
    const d = p.length / 1000;
    const y = core.blip({ freq: p.pitch, freqEnd: p.pitch * (1 - p.drop / 100), glide: d / 2, dur: d * 5, decay: d, sr: x.sr });
    return core.finish(core.warm(y, 4000, x.sr), p.volume, x.sr);
  },
},
```

**Tick**: the lightest feedback (picking up, a wheel tick, a slider detent).

```js
{
  key: 'tick', name: 'Tick', group: 'Touch', when: 'A piece is picked up; each wheel segment passes.',
  files: ['tick'],
  params: {
    pitch: [1400, 400, 3200, 10, 'Hz', 'Tone'],
    length: [8, 2, 40, 1, 'ms', 'Length'],
    volume: [0.18, 0.05, 0.8, 0.01, '', 'Loudness'],
    gameVolume: [0.5, 0, 1, 0.05, '', 'In-game volume'],
  },
  render(p, g, x) {
    const d = p.length / 1000;
    return core.finish(core.blip({ freq: p.pitch, dur: d * 6, decay: d, attack: 0.0005, sr: x.sr }), p.volume, x.sr);
  },
},
```

**Bubble pop**: a cute upward "bloop" (merges, bubbles, kids' apps).

```js
{
  key: 'pop', name: 'Bubble pop', group: 'Touch', when: 'A bubble is popped.',
  files: ['pop_0', 'pop_1', 'pop_2'],
  params: {
    from: [350, 150, 900, 10, 'Hz', 'Start tone'],
    to: [1100, 400, 2400, 10, 'Hz', 'End tone'],
    length: [60, 20, 160, 1, 'ms', 'Length'],
    variety: [5, 0, 12, 0.5, '%', 'Pitch variety'],
    volume: [0.4, 0.05, 0.9, 0.01, '', 'Loudness'],
    gameVolume: [0.8, 0, 1, 0.05, '', 'In-game volume'],
  },
  render(p, g, x) {
    const r = [1, 1 + p.variety / 100, 1 - p.variety / 100][x.index % 3];
    const d = p.length / 1000;
    const y = core.blip({ freq: p.from * r, freqEnd: p.to * r, glide: d / 3, dur: d * 1.6, decay: d / 2, sr: x.sr });
    return core.finish(y, p.volume, x.sr);
  },
},
```

### Action

**Soft thud**: something lands or drops (body plus a little texture).

```js
{
  key: 'thud', name: 'Drop', group: 'Gameplay', when: 'An item lands.',
  files: ['thud_0', 'thud_1'],
  params: {
    pitch: [190, 90, 400, 5, 'Hz', 'Body tone'],
    texture: [0.35, 0, 1, 0.05, '', 'Texture'],
    length: [70, 30, 200, 1, 'ms', 'Length'],
    volume: [0.55, 0.1, 0.9, 0.01, '', 'Loudness'],
    gameVolume: [0.9, 0, 1, 0.05, '', 'In-game volume'],
  },
  render(p, g, x) {
    const sr = x.sr;
    const d = p.length / 1000;
    const f = p.pitch * (x.index ? 1.04 : 1);
    const out = core.silence(d * 4, sr);
    // Triangle gives the low body some harmonics, so it survives phone speakers.
    core.mixInto(out, core.blip({ freq: f * 1.5, freqEnd: f, glide: 0.01, dur: d * 4, decay: d, shape: 'triangle', sr }), 0, sr, 1);
    core.mixInto(out, core.noiseHit({ dur: d * 2, decay: d / 3, tone: 1800, seed: 20 + x.index, sr }), 0, sr, p.texture);
    return core.finish(core.warm(out, 3000, sr), p.volume, sr);
  },
},
```

**Jump**: a rising retro glide.

```js
{
  key: 'jump', name: 'Jump', group: 'Player', when: 'The player jumps.',
  files: ['jump'],
  params: {
    from: [260, 120, 600, 5, 'Hz', 'Start pitch'],
    to: [720, 300, 1600, 10, 'Hz', 'End pitch'],
    length: [0.16, 0.06, 0.4, 0.01, 's', 'Length'],
    volume: [0.45, 0.05, 0.9, 0.01, '', 'Loudness'],
    gameVolume: [0.7, 0, 1, 0.05, '', 'In-game volume'],
  },
  render(p, g, x) {
    const y = core.blip({ freq: p.from, freqEnd: p.to, glide: p.length / 3, dur: p.length, decay: p.length * 0.7, shape: 'square', sr: x.sr });
    return core.finish(core.warm(y, 3500, x.sr), p.volume, x.sr);
  },
},
```

**Laser / zap**: a fast falling saw.

```js
{
  key: 'laser', name: 'Laser', group: 'Combat', when: 'The player shoots.',
  files: ['laser'],
  params: {
    from: [1600, 600, 3000, 10, 'Hz', 'Start pitch'],
    to: [220, 80, 800, 10, 'Hz', 'End pitch'],
    length: [0.14, 0.05, 0.4, 0.01, 's', 'Length'],
    volume: [0.35, 0.05, 0.9, 0.01, '', 'Loudness'],
    gameVolume: [0.6, 0, 1, 0.05, '', 'In-game volume'],
  },
  render(p, g, x) {
    const y = core.blip({ freq: p.from, freqEnd: p.to, glide: p.length / 4, dur: p.length, decay: p.length / 2, shape: 'saw', sr: x.sr });
    return core.finish(core.warm(y, 3500, x.sr), p.volume, x.sr);
  },
},
```

**Card swipe / paper**: a short band of noise.

```js
{
  key: 'swipe', name: 'Card swipe', group: 'Gameplay', when: 'A card is dealt or swiped away.',
  files: ['swipe_0', 'swipe_1'],
  params: {
    length: [0.09, 0.03, 0.3, 0.005, 's', 'Length'],
    low: [900, 200, 3000, 10, 'Hz', 'Low edge'],
    high: [5000, 2000, 10000, 100, 'Hz', 'High edge'],
    volume: [0.35, 0.05, 0.9, 0.01, '', 'Loudness'],
    gameVolume: [0.7, 0, 1, 0.05, '', 'In-game volume'],
  },
  render(p, g, x) {
    const sr = x.sr;
    const y = core.bandpass(core.noise(p.length * 1.5, sr, 40 + x.index), p.low, p.high, sr);
    for (let i = 0; i < y.length; i++) { const t = i / sr / p.length; y[i] *= t < 1 ? Math.sin(Math.PI * t) : 0; }
    return core.finish(y, p.volume, sr);
  },
},
```

### Feedback

**Gentle error**: noticeable, never alarming.

```js
{
  key: 'error', name: 'Error', group: 'Feedback', when: 'Invalid input or a failed action.',
  files: ['error'],
  params: {
    pitch: [260, 120, 500, 5, 'Hz', 'Tone'],
    gap: [90, 40, 200, 1, 'ms', 'Gap'],
    length: [60, 20, 150, 1, 'ms', 'Note length'],
    volume: [0.45, 0.05, 0.9, 0.01, '', 'Loudness'],
    gameVolume: [0.7, 0, 1, 0.05, '', 'In-game volume'],
  },
  render(p, g, x) {
    const d = p.length / 1000;
    const note = (f) => core.blip({ freq: f, freqEnd: f * 0.97, dur: d * 3, decay: d, shape: 'triangle', sr: x.sr });
    const y = core.sequence([[0, note(p.pitch), 1], [p.gap / 1000, note(p.pitch * 0.944), 1]], p.gap / 1000 + d * 3, x.sr);
    return core.finish(core.warm(y, 1400, x.sr), p.volume, x.sr);
  },
},
```

**Success**: three rising bell notes.

```js
{
  key: 'success', name: 'Success', group: 'Feedback', when: 'A task completes.',
  files: ['success'],
  params: {
    note: [5, 0, 10, 1, 'note', 'First note'],
    gap: [70, 30, 160, 1, 'ms', 'Gap'],
    ring: [0.6, 0.2, 1.6, 0.05, 's', 'Ring length'],
    reverb: [0.2, 0, 0.6, 0.01, '', 'Echo'],
    volume: [0.6, 0.1, 0.9, 0.01, '', 'Loudness'],
    gameVolume: [0.9, 0, 1, 0.05, '', 'In-game volume'],
  },
  render(p, g, x) {
    const sr = x.sr;
    const gap = p.gap / 1000;
    const y = core.sequence([0, 2, 4].map((k, n) => [n * gap, core.bell(x.hz(p.note + k), p.ring * (n === 2 ? 1.4 : 1), 0.8, sr), n === 2 ? 1 : 0.8]), gap * 2 + p.ring * 1.4, sr);
    return core.finish(core.reverb(y, { sr, wet: p.reverb, size: 0.8, tail: 1 }), p.volume, sr);
  },
},
```

**Notification**: a plucked pair.

```js
{
  key: 'notify', name: 'Notification', group: 'Feedback', when: 'A message arrives while the app is open.',
  files: ['notify'],
  params: {
    note: [9, 4, 14, 1, 'note', 'Top note'],
    gap: [80, 30, 200, 1, 'ms', 'Gap'],
    ring: [0.9, 0.3, 2, 0.05, 's', 'Ring length'],
    volume: [0.6, 0.1, 0.9, 0.01, '', 'Loudness'],
    gameVolume: [0.9, 0, 1, 0.05, '', 'In-game volume'],
  },
  render(p, g, x) {
    const sr = x.sr;
    const opts = { decay: 0.997, blend: 0.45 };
    const y = core.sequence([[0, core.pluck(x.hz(p.note - 2), p.ring, sr, opts), 0.8], [p.gap / 1000, core.pluck(x.hz(p.note), p.ring, sr, opts), 1]], p.gap / 1000 + p.ring, sr);
    return core.finish(core.warm(y, 5000, sr), p.volume, sr);
  },
},
```

### Rewards

**Chime with combo ladder**: one file per combo level, each a scale step
higher. This is the core of "satisfying" puzzle feedback.

```js
{
  key: 'clear', name: 'Clear chime', group: 'Rewards', when: 'Lines clear; level N = combo N (capped at 6).',
  files: ['clear_1', 'clear_2', 'clear_3', 'clear_4', 'clear_5', 'clear_6'],
  chipLabel: '×{n}', chipGroupLabel: 'Combo level',
  params: {
    startNote: [5, 0, 10, 1, 'note', 'Starting note'],
    climb: [1, 1, 3, 1, 'count', 'Climb per level'],
    gap: [55, 15, 160, 1, 'ms', 'Note spacing'],
    ring: [1.3, 0.3, 3, 0.05, 's', 'Ring length'],
    reverb: [0.3, 0, 0.7, 0.01, '', 'Echo'],
    volume: [0.8, 0.1, 0.9, 0.01, '', 'Loudness'],
    gameVolume: [1, 0, 1, 0.05, '', 'In-game volume'],
  },
  render(p, g, x) {
    const sr = x.sr;
    const i = p.startNote + x.index * p.climb;
    const gap = p.gap / 1000;
    const ev = [[0, core.bell(x.hz(i) / 2, p.ring * 0.8, 0.3, sr), 0.25]]; // quiet body note an octave down
    [0, 2, 4].forEach((k, n) => ev.push([n * gap, core.bell(x.hz(i + k), p.ring, 1, sr), 1]));
    const y = core.sequence(ev, p.ring + gap * 3 + 0.1, sr);
    return core.finish(core.reverb(y, { sr, wet: p.reverb, size: 0.84, tail: 1.6 }), p.volume, sr);
  },
},
```

**Coin**: two bright taps, the second higher.

```js
{
  key: 'coin', name: 'Coin', group: 'Rewards', when: 'A coin or small reward is collected.',
  files: ['coin'],
  params: {
    note1: [13, 8, 18, 1, 'note', 'First note'],
    note2: [15, 8, 20, 1, 'note', 'Second note'],
    gap: [70, 20, 200, 1, 'ms', 'Gap'],
    ring: [0.8, 0.2, 2, 0.05, 's', 'Ring length'],
    brightness: [1.3, 0.2, 2.5, 0.05, '×', 'Brightness'],
    volume: [0.5, 0.1, 0.9, 0.01, '', 'Loudness'],
    gameVolume: [0.8, 0, 1, 0.05, '', 'In-game volume'],
  },
  render(p, g, x) {
    const sr = x.sr;
    const gap = p.gap / 1000;
    const y = core.sequence([[0, core.bell(x.hz(p.note1), p.ring * 0.75, p.brightness, sr), 1], [gap, core.bell(x.hz(p.note2), p.ring, p.brightness, sr), 1]], gap + p.ring + 0.05, sr);
    return core.finish(core.reverb(y, { sr, wet: 0.2, size: 0.8, tail: 1 }), p.volume, sr);
  },
},
```

**Sparkle run**: a quick high shimmer, layered on bigger moments.

```js
{
  key: 'sparkle', name: 'Sparkle', group: 'Rewards', when: 'Layered on top of multi-line clears.',
  files: ['sparkle'],
  params: {
    notes: [7, 3, 14, 1, 'count', 'Notes'],
    gap: [32, 12, 90, 1, 'ms', 'Note spacing'],
    ring: [0.7, 0.2, 2, 0.05, 's', 'Ring length'],
    volume: [0.45, 0.05, 0.9, 0.01, '', 'Loudness'],
    gameVolume: [0.8, 0, 1, 0.05, '', 'In-game volume'],
  },
  render(p, g, x) {
    const sr = x.sr;
    const gap = p.gap / 1000;
    const ev = [];
    for (let k = 0; k < p.notes; k++) ev.push([k * gap, core.bell(x.hz(12 + (k % 5) + Math.floor(k / 5) * 2), p.ring, 1.4, sr), 0.6]);
    const y = core.sequence(ev, p.notes * gap + p.ring + 0.05, sr);
    return core.finish(core.reverb(y, { sr, wet: 0.35, size: 0.84, tail: 1.4 }), p.volume, sr);
  },
},
```

**Power-up**: a fast rising arpeggio.

```js
{
  key: 'powerup', name: 'Power-up', group: 'Rewards', when: 'A power-up is collected.',
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
    for (let k = 0; k < p.notes; k++) {
      const n = core.blip({ freq: x.hz(k), dur: 0.09, decay: 0.05, shape: k % 2 ? 'triangle' : 'square', attack: 0.003, sr: x.sr });
      ev.push([k * gap, core.warm(n, 3500, x.sr), 0.9]);
    }
    return core.finish(core.sequence(ev, p.notes * gap + 0.1, x.sr), p.volume, x.sr);
  },
},
```

**Level up**: an arpeggio into a held chord.

```js
{
  key: 'levelup', name: 'Level up', group: 'Rewards', when: 'Player level up, big prize, purchase.',
  files: ['levelup'],
  params: {
    gap: [80, 30, 200, 1, 'ms', 'Note spacing'],
    ring: [1.2, 0.4, 3, 0.05, 's', 'Ring length'],
    reverb: [0.3, 0, 0.7, 0.01, '', 'Echo'],
    volume: [0.75, 0.1, 0.9, 0.01, '', 'Loudness'],
    gameVolume: [1, 0, 1, 0.05, '', 'In-game volume'],
  },
  render(p, g, x) {
    const sr = x.sr;
    const gap = p.gap / 1000;
    const ev = [5, 7, 8, 10].map((n, k) => [k * gap, core.bell(x.hz(n), p.ring, 1, sr), 1]);
    const at = 4 * gap + 0.04;
    [10, 12, 13].forEach((n) => ev.push([at, core.bell(x.hz(n), p.ring * 1.5, 1, sr), 0.6]));
    const y = core.sequence(ev, at + p.ring * 1.5 + 0.1, sr);
    return core.finish(core.reverb(y, { sr, wet: p.reverb, size: 0.84, tail: 1.8 }), p.volume, sr);
  },
},
```

### Moments

**Whoosh**: band-passed noise that swells. Use it for clears, transitions
and swipes across the screen.

```js
{
  key: 'whoosh', name: 'Whoosh', group: 'Moments', when: 'A row clears / a screen slides in.',
  files: ['whoosh'],
  params: {
    low: [450, 80, 1500, 10, 'Hz', 'Low edge'],
    high: [2600, 800, 9000, 50, 'Hz', 'High edge'],
    length: [0.42, 0.12, 1.2, 0.01, 's', 'Length'],
    volume: [0.32, 0.05, 0.9, 0.01, '', 'Loudness'],
    gameVolume: [0.7, 0, 1, 0.05, '', 'In-game volume'],
  },
  render(p, g, x) {
    const sr = x.sr;
    const y = core.bandpass(core.noise(p.length + 0.08, sr, 202), p.low, p.high, sr);
    for (let i = 0; i < y.length; i++) { const s = Math.sin(Math.PI * Math.min(1, i / sr / p.length)); y[i] *= s * s; }
    return core.finish(core.reverb(y, { sr, wet: 0.2, size: 0.84, tail: 0.8 }), p.volume, sr);
  },
},
```

**Game over (calm)**: three descending, warm bells.

```js
{
  key: 'gameover', name: 'Game over', group: 'Moments', when: 'No moves left / the run ends.',
  files: ['gameover'],
  params: {
    startNote: [9, 4, 12, 1, 'note', 'First note'],
    gap: [240, 80, 600, 5, 'ms', 'Note spacing'],
    ring: [1.8, 0.5, 4, 0.05, 's', 'Ring length'],
    warmth: [2200, 600, 8000, 50, 'Hz', 'Brightness'],
    volume: [0.55, 0.1, 0.9, 0.01, '', 'Loudness'],
    gameVolume: [1, 0, 1, 0.05, '', 'In-game volume'],
  },
  render(p, g, x) {
    const sr = x.sr;
    const gap = p.gap / 1000;
    const ev = [0, -2, -4].map((d, k) => [k * gap, core.bell(x.hz(p.startNote + d), p.ring, 0.4, sr), 1]);
    const y = core.warm(core.sequence(ev, gap * 2 + p.ring + 0.1, sr), p.warmth, sr);
    return core.finish(core.reverb(y, { sr, wet: 0.4, size: 0.84, tail: 2.2 }), p.volume, sr);
  },
},
```

## 4. Patterns

- **Variants** (frequent sounds): `files: ['hit_0', 'hit_1', 'hit_2']`. In
  `render`, scale the pitch by
  `[1, 1 + v / 100, 1 - v / 100][x.index % 3]` and use a different noise
  seed per index. The game picks one at random each time.
- **Levels** (escalation): `files: ['clear_1' … 'clear_8']`, with
  `x.index` as the level. Raise the pitch by scale degrees, not Hz, so every
  level stays in key. Set `chipLabel: '×{n}'` so the page shows the levels.
- **Layers** (big moments): keep them as separate sounds (clear + sweep +
  sparkle) and play them together in code. That way each one has its own
  knob, and the scenario pads let the person hear the stack.
- **Loops**: render the full length plus the tail, then
  `core.loopFold(y, loopSec, sr)` and `core.peakNormalize(loop, p.volume)`.
  Let the music's events start at 0 and be spaced so the last bar leads
  back into the first. A loop length that is a whole number of bars keeps
  the tempo steady across the seam.
- **Global knobs**: anything that should move the whole set together, such
  as the key (`transpose`), brightness (multiply filter cut-offs by
  `g.brightness`) or room (`size: g.room` in `reverb`). Keep it to two or
  three.
