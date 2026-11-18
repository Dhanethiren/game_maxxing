# Playing the sounds in a project

Read this at workflow step 7. Every engine needs the same five things:

1. **Load by file name.** The code refers to `clear_3`, `place_1` and so on,
   exactly as in the config's `files`.
2. **Apply `mix.json`.** Play each file at `mix[name]` (default 1), times any
   user volume. This is how the studio's "In-game volume" knobs reach the
   game.
3. **Pool frequent sounds.** Two to four voices each, preloaded, so taps and
   placements never wait or cut each other off.
4. **Pick the file.** Choose a random variant (`place_${rand(3)}`), or the
   level for escalations (`clear_${min(combo, 8)}`).
5. **Run the music loop.** Loop it at its `mix.json` volume, pause it when
   the app is in the background, and give it a toggle separate from sound
   effects.

Set `outDir` in the config to wherever the engine loads audio from
(Flutter `assets/sounds`, Unity `Assets/Resources/sounds`, Godot
`assets/sounds`, web `public/sounds`).

**File names.** Use lowercase letters, digits and `_` only. Android
`res/raw` and several engines reject other characters.

## Contents
- Flutter (audioplayers)
- Unity
- Godot 4
- Web (Web Audio API)
- React Native / Expo
- Native Android and iOS
- Formats and compression
- SOUNDS.md template

## Flutter (audioplayers)

`pubspec.yaml`: add `audioplayers` and list `assets/sounds/` under
`flutter: assets:`.

```dart
import 'dart:convert';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class Sounds {
  final _pools = <String, AudioPool>{};
  final _mix = <String, double>{};
  final _rng = Random();
  AudioPlayer? _music;
  bool sfxOn = true, musicOn = true;

  Future<void> init(List<String> names) async {
    try {
      final data = jsonDecode(await rootBundle.loadString('assets/sounds/mix.json')) as Map<String, dynamic>;
      data.forEach((k, v) => _mix[k] = (v as num).toDouble());
    } catch (_) {}
    // Mix with the player's own audio and respect the silent switch.
    await AudioPlayer.global.setAudioContext(
      AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers, respectSilence: true).build(),
    );
    for (final n in names) {
      _pools[n] = await AudioPool.createFromAsset(path: 'sounds/$n.wav', maxPlayers: 3);
    }
  }

  void play(String name) {
    if (!sfxOn) return;
    _pools[name]?.start(volume: _mix[name] ?? 1.0);
  }

  void place() => play('place_${_rng.nextInt(3)}');
  void clear(int combo) => play('clear_${combo.clamp(1, 8)}');

  /// Call with false from didChangeAppLifecycleState when not resumed.
  Future<void> music({bool foreground = true}) async {
    if (musicOn && foreground) {
      final p = _music ??= AudioPlayer();
      await p.setReleaseMode(ReleaseMode.loop);
      await p.setVolume(_mix['music_loop'] ?? 0.35);
      if (p.state == PlayerState.paused) { await p.resume(); }
      else if (p.state != PlayerState.playing) { await p.play(AssetSource('sounds/music_loop.wav')); }
    } else {
      await _music?.pause();
    }
  }
}
```

Wrap everything in try/catch: sound is a nice-to-have and must never crash
the app. In tests, use a silent implementation of the same interface.

## Unity

Set `outDir` to `Assets/Resources/sounds`, relative to the config. For
music, select the clip and set **Load Type: Streaming**; leave SFX as
**Decompress On Load**.

```csharp
using System.Collections.Generic;
using UnityEngine;
using Newtonsoft.Json; // package com.unity.nuget.newtonsoft-json

public class Sounds : MonoBehaviour {
  public AudioSource sfx;    // for one-shots
  public AudioSource music;  // loop = true
  Dictionary<string, float> mix = new();
  Dictionary<string, AudioClip> clips = new();

  void Awake() {
    var json = Resources.Load<TextAsset>("sounds/mix");
    if (json != null) mix = JsonConvert.DeserializeObject<Dictionary<string, float>>(json.text);
  }

  AudioClip Clip(string name) {
    if (!clips.TryGetValue(name, out var c)) clips[name] = c = Resources.Load<AudioClip>("sounds/" + name);
    return c;
  }

  public void Play(string name) => sfx.PlayOneShot(Clip(name), mix.TryGetValue(name, out var v) ? v : 1f);
  public void Clear(int combo) => Play("clear_" + Mathf.Clamp(combo, 1, 8));

  public void StartMusic() {
    music.clip = Clip("music_loop");
    music.loop = true;
    music.volume = mix.TryGetValue("music_loop", out var v) ? v : 0.35f;
    music.Play();
  }

  void OnApplicationPause(bool paused) { if (paused) music.Pause(); else music.UnPause(); }
}
```

## Godot 4

Files in `res://assets/sounds/`. For music, select the WAV and set
**Import → Loop Mode: Forward**. Add `*.json` to the export filter so
`mix.json` ships.

```gdscript
extends Node
var mix := {}
var pools := {}  # name -> AudioStreamPlayer

func _ready() -> void:
    var text := FileAccess.get_file_as_string("res://assets/sounds/mix.json")
    if text != "":
        mix = JSON.parse_string(text)

func play(name: String) -> void:
    if not pools.has(name):
        var p := AudioStreamPlayer.new()
        p.stream = load("res://assets/sounds/%s.wav" % name)
        p.max_polyphony = 4
        add_child(p)
        pools[name] = p
    var player: AudioStreamPlayer = pools[name]
    player.volume_db = linear_to_db(float(mix.get(name, 1.0)))
    player.play()

func clear(combo: int) -> void:
    play("clear_%d" % clampi(combo, 1, 8))
```

For music, use a dedicated `AudioStreamPlayer` on a "Music" bus, so its
volume and mute are separate from the effects.

## Web (Web Audio API)

```js
const ctx = new AudioContext();
const buffers = {};
let mix = {};

export async function loadSounds(names, base = '/sounds/') {
  mix = await fetch(base + 'mix.json').then((r) => r.json()).catch(() => ({}));
  await Promise.all(names.map(async (n) => {
    const data = await fetch(base + n + '.wav').then((r) => r.arrayBuffer());
    buffers[n] = await ctx.decodeAudioData(data);
  }));
}

export function play(name, { loop = false } = {}) {
  if (ctx.state === 'suspended') ctx.resume(); // browsers need a user gesture first
  const src = ctx.createBufferSource();
  src.buffer = buffers[name];
  src.loop = loop;
  const gain = ctx.createGain();
  gain.gain.value = mix[name] ?? 1;
  src.connect(gain).connect(ctx.destination);
  src.start();
  return src; // keep it to .stop() a loop
}

document.addEventListener('visibilitychange', () => (document.hidden ? ctx.suspend() : ctx.resume()));
```

Decoded `AudioBuffer` loops are sample-accurate, so a folded loop is
seamless. An `<audio loop>` element often leaves a gap; avoid it for music.

## React Native / Expo

With `expo-audio`, create one player per frequent sound (two for overlap),
set `player.volume = mix[name] ?? 1`, and replay with `player.seekTo(0);
player.play()`. For music, set `player.loop = true`. Import `mix.json`
directly (`import mix from './assets/sounds/mix.json'`), and map file names
to `require(...)` calls, because bundlers need static requires. Configure
the audio mode to mix with other apps (on iOS, do not take exclusive
focus).

## Native Android and iOS

**Android (SoundPool for effects, MediaPlayer or ExoPlayer for music).**
Files go in `res/raw/` with lowercase names.

```kotlin
val pool = SoundPool.Builder().setMaxStreams(8)
    .setAudioAttributes(AudioAttributes.Builder()
        .setUsage(AudioAttributes.USAGE_GAME)
        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION).build())
    .build()
val ids = mapOf("tap" to pool.load(context, R.raw.tap, 1) /* ... */)
fun play(name: String) { val v = mix[name] ?: 1f; pool.play(ids.getValue(name), v, v, 1, 0, 1f) }
```

**iOS (AVAudioPlayer or AVAudioEngine).**

- Set `AVAudioSession.sharedInstance().setCategory(.ambient)`. That mixes
  with the person's music and respects the silent switch.
- Preload each player with `prepareToPlay()` and set `volume = mix[name]`.
- For music, set `numberOfLoops = -1`.
- Pause the music in `sceneDidEnterBackground`.

## Formats and compression

- **Effects:** keep 16-bit mono WAV, as rendered. They are small, decode
  instantly and work everywhere.
- **Music:** at 22.05 kHz mono, a 32 s WAV is about 1.4 MB. That is usually
  fine. If size matters:

  ```bash
  ffmpeg -i music_loop.wav -c:a libvorbis -q:a 4 music_loop.ogg
  ```

  ```bash
  ffmpeg -i music_loop.wav -c:a aac -b:a 96k music_loop.m4a
  ```

  OGG Vorbis plays on Android, the web (not older Safari), Unity and Godot.
  **iOS cannot play OGG**: use M4A/AAC there.
- **Loops:** MP3 and AAC encoders add a little padding at the start, which
  can leave a gap at the loop point in some players. After converting,
  re-test the loop on a device, or keep loops as WAV.
- After converting, update the file extension in code. `mix.json` keys are
  names without extensions, so they still match.

## SOUNDS.md template

```markdown
# <Project> sounds

All files in `<outDir>` are synthesised by `tool/sound/` from
`tool/sound/sounds.config.js`: original and royalty-free.

**Tweak them by ear:** <studio URL>. Move the sliders, then press
**Save for Claude** and tell Claude "apply my sound settings".

Rebuild from the saved design (`tool/sound/settings.json`):
`node tool/sound/render.js` · rebuild the studio page:
`node tool/sound/build_studio.js`

| # | File | Length | Plays when… (exact trigger) | In-game volume |
|---|---|---|---|---|
| 1 | `place_0..2.wav` | 0.8 s | A block lands on the board. One of three variants at random. | 1.0 |
| 2 | `clear_1..8.wav` | 1.8 s | One or more lines clear. The number is the combo level (capped at 8). | 1.0 |
| … | | | | |

## Order of sounds in one big moment
1. `place_?` (instant)
2. `clear_3` + `sweep` + `sparkle` (together)
3. `perfect` if the board is now empty
```

Fill the lengths and volumes from `analyze.js` and `mix.json`. Take each
trigger from the code, not from memory.
