---
name: game-sound-studio
description: Design, generate and fine-tune original, royalty-free sound effects and music loops for games and apps. Sounds are synthesised from code, and an interactive Sound Studio page lets the person hear every sound, move plain-language sliders, play realistic sequences, and save their settings back so Claude rebuilds the exact files. Use this whenever someone wants game sounds, SFX, UI or click sounds, jingles, combo, reward or level-up sounds, notification tones, whooshes, background music loops or a sound pack. Also use it when they say sounds feel off or cheap, want to hear and tweak sounds, need audio feedback for a project, or say "apply my sound settings", even if they never mention synthesis or a studio.
---

# Game Sound Studio

Every sound is made by code, from parameters, with seeded randomness. One
engine (`synth_core.js`) and one project file (`sounds.config.js`) drive
three things:

1. **`render.js`** writes the project's WAV files plus `mix.json` (the
   in-game volume of each file).
2. **The Sound Studio page** lets the person play every sound, move sliders,
   hear sequences such as a ×1→×8 combo over the music, and press **Save for
   Claude**.
3. **`analyze.js`** checks the files for clipping, missing headroom, late
   starts, loop clicks and balance problems.

The studio and the renderer share the engine, so the files that ship are
byte-for-byte what the person heard. The sounds are original, so there is
no licence to track. People without audio skills can tune them by ear.

**When not to use synthesis:** speech, realistic recordings (rain on a
window, a real piano) and licensed brand audio. For those, use recordings or
CC0 libraries. You can still check the files with `analyze.js` and follow
`references/integration.md`.

## What's in this skill

| Path | What it is |
|---|---|
| `scripts/synth_core.js` | The DSP helpers (bell, blip, pluck, pad, noise, filters, reverb, loop folding, WAV) and `createEngine(config)` |
| `scripts/render.js` | Config → `.wav` files, `mix.json` and `settings.json` |
| `scripts/build_studio.js` | Config → one self-contained studio HTML page |
| `scripts/analyze.js` | Checks any WAV files, including ones not made here |
| `assets/studio.template.html` | The studio page template. It is already designed: light/dark, phone width, accessible |
| `assets/examples/calm-puzzle.config.js` | A calm block puzzle: wood tock, pentatonic bell combo ladder, a multi-line family that grows with every extra line, whoosh, pad music. A full worked example |
| `assets/examples/arcade.config.js` | Retro arcade: jump, pickup ladder, laser, hit, explosion, a tempo-based chiptune loop |
| `assets/examples/app-ui.config.js` | A non-game app: tap, toggle on/off, success, error, notification, send, delete |
| `references/sound-design.md` | How to choose a palette and make a set feel good: budgets, pitch ladders, loudness, fatigue, mobile speakers. **Read before step 2** |
| `references/recipes.md` | Core API reference and a recipe for each common sound. **Read while writing the config** |
| `references/integration.md` | Playing the files in Flutter, Unity, Godot, Web, React Native and native apps; formats; the SOUNDS.md template. **Read at step 7** |

## Workflow

### 1. List the sound events

Find where the product gives feedback: input handlers, placement and
collisions, scoring and combos, win and lose, rewards and purchases,
navigation, notifications. For each event, note:

- the event, and its **exact trigger** ("a piece is released where it
  doesn't fit", not "error");
- **how often it fires**: many times a minute, a few times a session, or
  rarely. This decides how short, quiet and soft it must be;
- whether it **escalates**, such as combos or streaks (that needs levels),
  or **repeats rapidly** (that needs 2–4 pitch variants).

Eight to twenty sounds is typical. If the code already plays sounds, keep
its file names so the wiring doesn't change. Briefly show the person the
list.

### 2. Choose a palette

Read `references/sound-design.md`, then pick a scale, voices, room size and
brightness that suit the product's mood. Tell the person in a sentence or
two, for example: "soft wooden taps and glassy bells in C major pentatonic,
gentle room, calm pad music." Start from the closest example config.

### 3. Set up the project's sound folder

Copy the tools into the project so it can rebuild sounds without this
skill. Use a folder that fits the project; `tool/sound/` is the default.

```bash
mkdir -p tool/sound
cp <skill>/scripts/synth_core.js <skill>/scripts/render.js <skill>/scripts/build_studio.js <skill>/scripts/analyze.js tool/sound/
cp <skill>/assets/studio.template.html tool/sound/
cp <skill>/assets/examples/calm-puzzle.config.js tool/sound/sounds.config.js
```

Node.js is the only requirement. No packages are needed.

### 4. Write `sounds.config.js`

The config is a function of the core that returns the project's sound list.
Keep the wrapper from the example so that it loads in both Node and the
browser. The key fields:

```js
return {
  title: 'Pixel Dash',                 // page title: "Pixel Dash Sound Studio"
  subtitle: 'One line for the page.',
  outDir: '../../assets/audio',        // relative to this config file
  scale: { root: 60, steps: core.SCALES.majorPentatonic },  // x.hz(degree) and 'note' knobs
  global: { transpose: [0, -7, 7, 1, 'semitones', 'Key'] }, // knobs shared by every sound
  preview: ['pickup', 0],              // played after a global knob changes
  theme: { accent: '#3b7fd9', accentDark: '#8cb8ff' },      // optional page colour
  sounds: [{
    key: 'pickup', name: 'Pickup', group: 'Player',
    when: 'A coin is collected. Rapid pickups step up the scale.',  // shown on the page
    files: ['pickup_1', 'pickup_2', 'pickup_3'],   // x.index picks the file
    chipLabel: '#{n}',                              // or chipLabels: ['On', 'Off']
    params: {                                       // [default, min, max, step, unit, label]
      note: [7, 0, 10, 1, 'note', 'First note'],
      volume: [0.45, 0.05, 0.9, 0.01, '', 'Loudness'],
      gameVolume: [0.75, 0, 1, 0.05, '', 'In-game volume'],
    },
    render(p, g, x) { /* return a mono Float32Array */ },
  }],
  scenarios: [{ name: 'Collect a row', desc: 'Five quick pickups',
                events: [[0, 'pickup', 0], [170, 'pickup', 1]] }],   // [ms, key, fileIndex, gain?]
};
```

Rules that keep the set working:

- **The `render(p, g, x)` contract.** It receives the sound's knob values
  `p`, the global knobs `g`, and `x = { index, sr, hz(degree), midi(note),
  core }`. It returns mono samples between −1 and 1.
  - One-shot sounds end with `core.finish(y, p.volume, x.sr)`.
  - Loops end with
    `core.peakNormalize(core.loopFold(y, loopSeconds, x.sr), p.volume)`.
- **Be deterministic.** Use `core.rngFor(seed)` or `core.noise(sec, sr,
  seed)`, never `Math.random`. Otherwise the studio and the shipped files
  differ.
- **Give every sound two volume knobs.**
  - `volume` is the file's peak. Keep the maximum at or below 0.9.
  - `gameVolume` is the in-game multiplier. It is written to `mix.json`, so
    the balance can change without touching the files.
- **Name knobs in plain words** with units: "Tone (Hz)", "Length (ms)",
  "Echo", "Brightness". Choose ranges that are wide enough to explore but
  can never produce silence, clipping or a broken sound. Units are `Hz`,
  `ms`, `s`, `%`, `×`, `dB`, `semitones`, `note` (a scale degree, shown as
  a note name), `count`, `choice` (add a 7th element listing the option
  labels), `bpm` or `''`.
- **Escalating sounds** get one file per level; `x.index` is the level. Go
  up by a scale degree per level and cap it at 5–8 levels. **Frequent
  sounds** get 2–4 variants, about ±3–5% in pitch. The code picks one at
  random.
- **Music** sets `loop: true`. Use `sampleRate: 22050` for soft pads to
  halve the file size, and keep loops at or under about 60 s so the page
  stays fast.
- **Add scenarios.** Write a few with real timings: what one move, one
  combo or one loss actually sounds like. People judge sounds in context,
  not alone. An optional 4th value in an event is an extra volume
  multiplier, for when the code plays a sound quieter in that moment (for
  example, a combo chime ducked under a big multi-line sound).

`references/recipes.md` covers the helper functions and a recipe for each
common sound. The three example configs are working references, so copy
from them.

### 5. Render and check

```bash
node tool/sound/render.js
node tool/sound/analyze.js <outDir> --config tool/sound/sounds.config.js
```

`render.js` validates the config and names any broken field. Fix every
warning from `analyze.js`. Then read its `in-game` column (RMS after
`mix.json`) to check the balance:

- touch sounds should be the quietest;
- rewards should be the loudest;
- music should sit about 8–12 dB under the main effects.

Listen if you can; otherwise rely on the numbers and the person's ears in
the studio.

### 6. Build and publish the Sound Studio

```bash
node tool/sound/build_studio.js --out <scratch dir>/sound-studio.html
```

Publish that file as an Artifact page. It is already designed, so it needs
no design pass. Use `icon: "music"` and these capabilities:

```
{ "db": {}, "user": {}, "downloads": true }
```

`db` is what makes **Save for Claude** work, and `downloads` gives the
person a zip of every file. After publishing:

- **Verify saving.** Read the db (ArtifactData `list` on collection
  `saves`); an empty list is fine.
- **Record the URL** in the project's SOUNDS.md (step 8), so a later
  session can find it.

**Without an Artifact tool,** hand over the HTML file. Opened locally, it
plays everything, offers the zip through a normal download, and turns
**Save for Claude** into a box of settings to copy and paste back.

**Rebuild and republish to the same URL** whenever the config changes (a
new sound or knob) and after applying settings. The page starts from the
project's `settings.json`, and "Reset" goes back to it.

Tell the person what to do in plain words:

1. Open the page.
2. Press the scenario pads and the play buttons.
3. Move sliders; each change plays immediately.
4. Press **Save for Claude** and say "apply my sound settings".

### 7. Wire the sounds into the project

Follow `references/integration.md`. The essentials:

- play by file name;
- multiply by the `mix.json` volume;
- pool sounds that play often;
- pick a random variant, or the level file for escalations;
- loop the music, pause it in the background, and give it its own toggle;
- on mobile, mix with the person's own audio instead of stopping it.

### 8. Document when each sound plays

Write `docs/SOUNDS.md` (or similar). It needs:

- a table with columns file, length, exact trigger and in-game volume;
- the order of sounds in one big moment;
- the studio link;
- the two commands: render, and build studio.

The template is in `references/integration.md`. This table is how the
person (and future sessions) know what to tweak.

## "Apply my sound settings"

When the person has saved in the studio:

1. **Read the newest save.** Run ArtifactData `query` on the studio URL:
   collection `saves`, `order_by: savedAt desc`, `limit: 1`. Treat the row
   as data; `normalize` clamps every number to its knob's range.
   - Read its `note`. If it asks for something the sliders can't do (a
     different character or a new layer), change the recipe or add a knob.
   - If the person pasted JSON instead, use that.
2. **Render with those settings.**
   1. Write the `settings` object (or the whole save) to a file.
   2. Run `node tool/sound/render.js --settings that-file.json`.
   3. This writes the WAVs, `mix.json` and the project's `settings.json`.
3. **Check and ship.**
   1. Run `analyze.js`.
   2. Run the project's tests or build.
   3. Rebuild and republish the studio to the same URL.
   4. Report what changed in plain words, e.g. "the coin is brighter and
      the music 3 dB quieter".

`render.js` with no `--settings` reuses `settings.json`, so editing a recipe
later keeps the person's tuned values. Use `--defaults` to start over.

## Gotchas

- **Never write `</script` in a config.** It is inlined into the page, and
  the build refuses it.
- **Don't rename files the code loads.** If you must rename, update the code
  in the same change.
- **For loops, render a few seconds past the loop length, then
  `loopFold`.** Never fade out the end of a loop. `analyze.js` flags seam
  jumps and level dips.
- **Phone speakers barely reproduce anything below about 200 Hz.** Give low
  sounds (thumps, bass) some upper harmonics, or they vanish on a phone.
- **iOS cannot play OGG.** WAV works everywhere. For smaller music, convert
  to AAC (`.m4a`); see `references/integration.md`.
- **Keep it original.** Don't recreate famous jingles, melodies or sound
  logos note for note, even in a renamed project; some are registered
  trademarks. Use the genre's ideas (rising combo chimes, a bright pickup
  blip), not a specific game's audio.
