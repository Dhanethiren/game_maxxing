# Sound design guide

How to make a set of sounds feel good together: satisfying, readable, and
never tiring. Read this before choosing a palette (workflow step 2).

## Contents
1. What makes game audio feel good
2. A budget for each kind of sound
3. Pitch, scales and escalation
4. Palettes by mood
5. Loudness and mix
6. Avoiding fatigue
7. Phones and small speakers
8. Accessibility and respect
9. Originality

## 1. What makes game audio feel good

- **Every action answers.** A touch, a drop or a clear gets an immediate
  sound, so the action feels physical. Silence after an action feels broken.
  Latency matters more than polish: no silence at the start of the file, and
  pool the players so nothing has to load.
- **Praise escalates.** Candy Crush layers sound with escalating praise
  ("Sweet → Tasty → Delicious → Divine") to build a feeling of elevation
  ([Game Developer audio breakdown](https://www.gamedeveloper.com/audio/why-candy-crush-saga-is-so-engaging-an-audio-breakdown)).
  The sound version of that: combo and streak sounds climb in pitch.
- **Big moments sound bigger.** Tetris rewards a four-line clear far more
  than a single line. Layer extra elements, such as a sparkle, a run or a
  chord, for rarer achievements rather than just making them louder.
- **Material sells the fantasy.** Wood tocks for tile puzzles, glassy bells
  for gems, soft pops for bubbles. Choose one material family per product
  and stay in it.
- **Calm sets use consonant scales.** The pentatonic scale has no clashing
  intervals, so overlapping chimes always sound pleasant. A small 2024 EEG
  study found pentatonic sequences relaxing
  ([Frontiers in Psychology](https://pmc.ncbi.nlm.nih.gov/articles/PMC11056517/)).
- **Failure is gentle in casual games.** Losing should read clearly ("that's
  the end") without punishing: descending soft notes, no buzzers, no harsh
  noise.

## 2. A budget for each kind of sound

| Kind | Examples | Length | Peak (`volume`) | In-game (`gameVolume`) | Notes |
|---|---|---|---|---|---|
| Touch | tap, pickup, tick, toggle | 20–80 ms | 0.2–0.4 | 0.4–0.7 | The most frequent sounds, so the quietest. Mostly below about 2.5 kHz, little or no reverb |
| Core action | place, jump, shoot, swipe | 80–300 ms | 0.4–0.6 | 0.6–1 | 2–4 variants (±3–5% pitch), picked at random |
| Negative | invalid, error, bump | 60–300 ms | 0.3–0.5 | 0.6–0.8 | Low and soft, two notes at most. Never a buzzer |
| Small reward | coin, gem, line clear, success | 0.3–1.5 s | 0.5–0.8 | 0.8–1 | Bright but short. Escalating versions climb |
| Big reward | level up, perfect clear, unlock | 1.5–3 s | 0.75–0.9 | 1 | Runs, arpeggios, held chords. Rare, so they can be the loudest |
| Fail / game over | out of moves, run ends | 1.5–3 s | 0.5–0.7 | 1 | Descending, warm (low-passed), calm |
| Ambience / music | menu loop, level loop | 30–90 s loop | 0.5–0.6 | 0.25–0.45 | 8–12 dB under the effects. Sparse. Always switchable |

Longer loops repeat less obviously. Thirty seconds is a reasonable minimum
for something heard for minutes at a time.

## 3. Pitch, scales and escalation

- **One key for the whole set.** Use the `transpose` global knob. Every
  melodic sound then fits with every other sound and with the music.
- **Scales** (`core.SCALES`):

  | Scale | Character |
  |---|---|
  | `majorPentatonic` | Calm, happy, nothing ever clashes. The safest default |
  | `minorPentatonic` | Mellow, mysterious, still safe |
  | `major` | Bright and full; less forgiving when sounds overlap |
  | `dorian` | Adventure, folk |
  | `lydian` | Magical, floating |
  | `harmonicMinor` | Exotic, dramatic (bosses, desert) |
  | `wholeTone` | Dreamy, unresolved (transitions, magic) |

- **Escalation ladders.** Combos and streaks are one file per level, each one
  scale degree higher (or two for a steeper climb). Cap the ladder at 5–8
  levels, then hold the top level, so it never goes shrill. Chord-shaped
  sounds (a triad of degrees i, i+2, i+4) climb more musically than single
  notes.
- **Simultaneous layers.** Things that play together (clear + sweep +
  sparkle) should stay in the scale, and their important energy should sit
  in different registers: body low, chime middle, sparkle high.
- **Direction carries meaning.** Rising means gain, success, power-up.
  Falling means loss, closing, turning off. A toggle going on rises; going
  off falls.

## 4. Palettes by mood

| Mood | Voices (core) | Scale | Room (`reverb` wet / size) | Brightness |
|---|---|---|---|---|
| Calm / cozy / zen | `bell`, wood tock (calm example), `padNote`, `pluck` | majorPentatonic | 0.2–0.4 / 0.84 | Soft (low-pass ≈ 3–4 kHz on music) |
| Arcade / retro | `blip` square/triangle, `noiseHit`, short arps | major or minorPentatonic | 0–0.15 | Medium; low-pass square waves ≈ 3–4 kHz |
| Clean app UI | sine/triangle `blip`, `pluck`, short `bell` | major | 0–0.2 / 0.7 | Soft; touch sounds < 2.5 kHz |
| Fantasy / magic | `bell` with brightness 1.5–2, sparkle runs, `padNote` | lydian or majorPentatonic | 0.35–0.55 / 0.9 | Bright shimmer, warm pad |
| Sci-fi | saw/square `blip` glides, `bandpass` noise sweeps | minor, wholeTone | 0.2–0.4 | Bright, with pitch glides |
| Kids | rounded `blip` (sine/triangle), bouncy glides, `pluck` | majorPentatonic | 0.1–0.2 | Medium; nothing harsh or sudden |

## 5. Loudness and mix

- **Headroom.** Effects overlap: a clear, a sweep and a sparkle add up.
  Keep every file's peak at or below 0.9 (about −1 dBFS), and give layered
  sounds a lower `volume`.
- **Normalise the files, mix in the game.** Each file gets a healthy peak
  through `volume`. Relative loudness comes from `gameVolume`, which is
  written to `mix.json`, so the balance can be changed without re-rendering.
- **Check the `in-game` column of `analyze.js`.** That is RMS after
  `mix.json`. A sensible order from quiet to loud:
  1. touch
  2. negative
  3. core action
  4. small reward
  5. big reward

  The music sits about 8–12 dB under the main effects.
- **Ducking (optional).** Dip the music about 6 dB for a second during big
  moments to make them land.

## 6. Avoiding fatigue

- The more often a sound plays, the shorter, softer and less bright it
  should be. Energy in the 2–5 kHz range is what makes repeated sounds
  grating.
- Round-robin variants stop the "machine-gun" effect of identical repeats.
- Limit each sound to about 8 plays a second, and skip a new play if the
  same file started less than 30–50 ms ago.
- Avoid long reverb on frequent sounds; it smears into a wash.
- Music: sparse melody, slow harmonic rhythm (a chord change every 4–8 s for
  calm games), no sharp transients, no busy hi-hats in calm products.

## 7. Phones and small speakers

- Phone speakers reproduce little below about 200 Hz. A pure 120 Hz thump
  disappears. Add upper harmonics (overtones in the recipe, a triangle wave)
  so the ear fills in the fundamental.
- Test at low volume: the balance changes. Quiet details vanish; bright
  sounds stick out.
- Mono is fine and halves the size; the core writes mono.
- 44.1 kHz for effects; 22.05 kHz is enough for soft pads and ambience.

## 8. Accessibility and respect

- Give separate toggles for sound effects and music, and remember them.
- Never put important information only in sound. Pair it with visuals
  (and haptics on mobile).
- No sudden loud sounds, especially after quiet stretches.
- On mobile, mix with the person's own audio (podcasts, music) instead of
  stopping it, and respect the silent switch.

## 9. Originality

Sounds synthesised from this engine are original works. Don't reproduce a
recognisable melody, jingle or sound logo from another product, even
approximately. Some are registered sound trademarks, and a copied signature
sound invites trade-dress complaints. Genre conventions are fine: rising
combo chimes, a bright pickup blip, a descending game-over phrase. Write
your own notes, rhythm and timbre.
