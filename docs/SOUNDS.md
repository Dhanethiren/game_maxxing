# Calm Grid sound pack

All 22 audio files live in `assets/sounds/`. Every one is synthesised from
scratch by our own engine, `tool/sound/synth.js`, so they are original and
royalty-free.

## Tweak them by ear: the Sound Studio

The easiest way to change sounds is the **Calm Grid Sound Studio** page
(https://claude.ai/artifact/GNfJrf6d4XQab2hjd22jnh). It lets you:
- play every sound,
- move plain-language sliders (tone, length, echo, loudness, in-game
  volume…) and hear the change straight away,
- hear sounds in context, e.g. a ×1→×8 combo, a perfect clear or running out
  of moves, optionally over the music,
- press **Save for Claude**, then tell Claude "apply my sound settings".

The page and the game share one engine (`tool/sound/synth.js`), so the game
gets exactly what you heard. To rebuild the files yourself from saved
settings (needs Node.js):

```bash
node tool/sound/render.js my-settings.json
```

It writes every `.wav`, `assets/sounds/mix.json` (the in-game volume of each
file, read by the game) and `tool/sound/settings.json` (the current design,
kept in git).

To rebuild the studio page after changing the engine:

```bash
node tool/sound/build_studio.js
```

## When each sound plays

"Game volume" is the multiplier the app applies on top of the file's own
loudness (`lib/audio/sound_service.dart`). 1.0 means the file plays as is.

| # | File | Length | Plays when… (exact trigger) | Game volume |
|---|---|---|---|---|
| 1 | `place_0.wav`, `place_1.wav`, `place_2.wav` | 0.8 s | **A block lands on the board.** One of the three is picked at random each time (same "wooden tock", pitch ±4%) so repeated placing never sounds mechanical. | 1.0 |
| 2 | `pickup.wav` | 0.05 s | **Your finger touches a piece in the tray** (start of a drag). Also the **tick each time a segment passes the pointer on the Daily Spin wheel**. | 0.5 |
| 3 | `invalid.wav` | 0.14 s | **You release a piece over the board where it doesn't fit**, and it goes back to the tray. | 0.6 |
| 4 | `clear_1.wav` … `clear_8.wav` | ~1.8 s | **One or more lines clear.** The number is the **combo level**: `clear_1` for a first clear, `clear_2` when you clear again within 3 moves, and so on up to `clear_8` (higher combos stay on 8). Each step is a 3-note chime one scale step higher, so the pitch climbs as the combo builds. | 1.0 |
| 5 | `sweep.wav` | 1.0 s | **Every line clear**, together with `clear_N`. It's the soft "whoosh" that follows the band of light sweeping along the cleared row or column. | 0.7 |
| 6 | `sparkle.wav` | 1.3 s | **2 or more lines clear in one move**, layered on top of `clear_N` and `sweep`. | 0.8 |
| 7 | `perfect.wav` | 3.1 s | **The whole board is emptied** ("Perfect Clear!"), on top of the clear sounds. Also **when a Journey level is completed**, 0.7 s after the winning move. | 1.0 |
| 8 | `gameover.wav` | 2.6 s | **No more moves**: the instant none of your pieces fit, as the board fades to grey and the "No more moves" banner appears. | 1.0 |
| 9 | `revive.wav` | 1.6 s | **You revive after watching the ad**: the fullest rows clear and play resumes. | 1.0 |
| 10 | `coin.wav` | 1.1 s | Small rewards:<br>• a **daily goal completes** (once per goal, with the pop-up)<br>• a **gem is collected** in Journey<br>• **coins are doubled** after the ad on the game-over screen<br>• **free coins** arrive in Themes<br>• a **Daily Spin prize under 100 coins** | 0.8 |
| 11 | `levelup.wav` | 2.5 s | Big rewards:<br>• your **player level goes up** (0.9 s after the game-over panel appears)<br>• a **Journey level is completed** (0.9 s after `perfect`, as the stars pop in)<br>• the **daily reward is claimed**<br>• a **theme is bought**<br>• a **Daily Spin prize of 100+ coins** | 1.0 |
| 12 | `tap.wav` | 0.07 s | **Any button or icon is pressed** (menus, dialogs, settings toggles). | 0.7 |
| 13 | `music_loop.wav` | 32.0 s | **Background music.** Starts once the app has loaded (if Music is on), **loops seamlessly every 32 s**, pauses when the app goes to the background and resumes when you return. It can be switched off in Settings or the Pause menu. | 0.35 |

### Order of sounds in one big move (example)

The player drops a piece that clears 2 lines while on a ×3 combo:

1. `place_?` (instant)
2. `clear_3` + `sweep` + `sparkle` (same moment)
3. If this emptied the board, `perfect` also plays
4. If a daily goal completed, `coin`

## What's inside each sound

All melodic sounds use the **C major pentatonic** scale (C D E G A), so any
overlap sounds consonant.

- **place**: a soft wooden or clay "tock" around G4 (330 Hz) with a tiny
  pitch drop at the hit and a short reverb.
- **pickup**: a barely-there 1.4 kHz tick.
- **invalid**: a soft low bump around 150 Hz. Deliberately not a buzzer.
- **clear_N**: 3 bell notes 55 ms apart, starting at C5 and moving up one
  pentatonic step per level, plus a quiet octave-down body note and reverb.
- **sweep**: band-passed noise (450 to 2600 Hz) with a gentle swell.
- **sparkle**: 7 quick high bell notes, 32 ms apart.
- **perfect**: a 10-note run up the scale (45 ms apart) into a held
  4-note chord.
- **gameover**: 3 descending low-passed bells, A, G then E. Calm, not sad.
- **revive**: a rising 5-note shimmer.
- **coin**: two bright bell taps, G6 then C7.
- **levelup**: a C–E–G–C arpeggio into a chord.
- **tap**: a soft "pop" (620 Hz falling to 400 Hz).
- **music_loop**: 4 soft pad chords, 8 s each, plus sparse bells every 2 to
  4 s and a long reverb. The tail is folded back onto the start so the loop
  has no seam.

  | Time | Chord |
  |---|---|
  | 0–8 s | Cmaj9 |
  | 8–16 s | Am9 |
  | 16–24 s | Fmaj9 |
  | 24–32 s | G6/9sus |

## Sending tweaked files back

Keep these rules so they drop straight into the game:

1. **Same file names.** The game finds sounds by name.
2. **Format: WAV, 16-bit PCM, mono.** 44,100 Hz for effects. The music may
   stay at 22,050 Hz or go up to 44,100 Hz (that doubles its size).
3. **Leave headroom**: peaks no higher than about −1 dBFS (0.9). Effects
   overlap, so loud files will clip together.
4. **Keep short sounds short.** `pickup`, `tap` and `invalid` play on every
   touch. Keep them under about 0.2 s and quiet.
5. **`clear_1` to `clear_8` must keep rising in pitch**: that rise is the
   combo reward.
6. **The music must loop**: the end must flow into the start with no click
   or gap. Keep the length unchanged (32.0 s) or make sure the new length
   loops cleanly.
7. You don't need to touch the volume table. If a sound feels too loud or
   quiet *relative to the others*, tell me and I'll adjust the multiplier in
   code.

Then either send the files back to me, or put them in `assets/sounds/`
yourself and rebuild. Note: re-running `tool/sound/render.js` would
overwrite them. The Sound Studio is usually the easier route.
