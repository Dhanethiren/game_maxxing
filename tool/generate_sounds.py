#!/usr/bin/env python3
"""Synthesises every sound effect and the music loop for Calm Grid.

All audio is generated from scratch (no samples), so it is original and free
to ship. Design choices follow docs/RESEARCH.md:

* Notes come from the C major pentatonic scale: every combination sounds
  consonant, and pentatonic tones were rated the most relaxing in a 2024 EEG
  study (Costa et al., Frontiers in Psychology).
* Line-clear chimes rise one scale step per combo level (rising pitch = reward).
* Frequently repeated sounds (placing a block) come in 3 slightly different
  pitches (about ±4%) so they never feel mechanical.
* Soft attacks, warm low-passed tone, gentle reverb, nothing harsh.

Usage:  python3 tool/generate_sounds.py      (writes assets/sounds/*.wav)
"""

import os
import wave

import numpy as np

SR = 44100
MUSIC_SR = 22050
OUT = os.path.join(os.path.dirname(__file__), '..', 'assets', 'sounds')
rng = np.random.default_rng(7)

# C major pentatonic, C4 upward.
_PENTA_SEMITONES = [0, 2, 4, 7, 9]


def penta(index, base_midi=60):
    """Frequency of the index-th note of the C major pentatonic scale."""
    octave, step = divmod(index, 5)
    midi = base_midi + 12 * octave + _PENTA_SEMITONES[step]
    return 440.0 * 2 ** ((midi - 69) / 12)


def t_axis(seconds, sr=SR):
    return np.arange(int(seconds * sr)) / sr


def lowpass(x, cutoff, sr=SR):
    """One-pole low-pass, vectorised via FFT-domain filtering."""
    spec = np.fft.rfft(x)
    freqs = np.fft.rfftfreq(len(x), 1 / sr)
    spec *= 1 / np.sqrt(1 + (freqs / cutoff) ** 2)
    return np.fft.irfft(spec, len(x))


def reverb(x, seconds=1.4, wet=0.25, sr=SR, seed=3):
    """Convolution reverb with a synthetic, softly filtered noise tail."""
    r = np.random.default_rng(seed)
    n = int(seconds * sr)
    t = np.arange(n) / sr
    ir = r.standard_normal(n) * np.exp(-t / (seconds / 4.5))
    ir = lowpass(ir, 3500, sr)
    ir[: int(0.012 * sr)] = 0  # pre-delay
    ir /= np.sqrt(np.sum(ir ** 2)) + 1e-9
    size = len(x) + n
    wet_sig = np.fft.irfft(np.fft.rfft(x, size) * np.fft.rfft(ir, size), size)
    dry = np.concatenate([x, np.zeros(n)])
    return dry * (1 - wet) + wet_sig * wet * 3.0


def bell(freq, seconds=1.2, brightness=1.0, sr=SR):
    """Soft glassy bell / celesta tone."""
    t = t_axis(seconds, sr)
    partials = [(1.0, 1.0, 1.0), (2.0, 0.42, 0.65), (3.0, 0.2, 0.45),
                (4.17, 0.1 * brightness, 0.3), (5.43, 0.05 * brightness, 0.2)]
    out = np.zeros_like(t)
    for ratio, amp, decay in partials:
        if freq * ratio > sr / 2.2:
            continue
        out += amp * np.sin(2 * np.pi * freq * ratio * t) * np.exp(-t / (seconds * 0.28 * decay))
    attack = np.minimum(1, t / 0.004)
    return out * attack


def wood(freq, seconds=0.16):
    """Soft wooden/clay 'tock' for placing a block."""
    t = t_axis(seconds)
    bend = freq * (1 + 0.25 * np.exp(-t / 0.006))  # tiny pitch drop at the hit
    phase = 2 * np.pi * np.cumsum(bend) / SR
    body = np.sin(phase) * np.exp(-t / 0.045)
    body += 0.35 * np.sin(3.95 * phase) * np.exp(-t / 0.018)
    body += 0.12 * np.sin(9.1 * phase) * np.exp(-t / 0.008)
    click = rng.standard_normal(len(t)) * np.exp(-t / 0.0025) * 0.25
    return lowpass(body + lowpass(click, 2500), 4200) * np.minimum(1, t / 0.0015)


def place_notes(events, total, sr=SR):
    """Mix (start_seconds, signal) pairs into one buffer."""
    out = np.zeros(int(total * sr))
    for start, sig in events:
        i = int(start * sr)
        end = min(len(out), i + len(sig))
        out[i:end] += sig[: end - i]
    return out


def finish(x, peak, fade=0.02, sr=SR):
    x = x - np.mean(x)
    x = x / (np.max(np.abs(x)) + 1e-9) * peak
    n = int(fade * sr)
    if n:
        x[-n:] *= np.linspace(1, 0, n)
    # Trim trailing near-silence to keep files small.
    nz = np.where(np.abs(x) > 1e-3)[0]
    return x[: nz[-1] + n + 1] if len(nz) else x


def write(name, x, sr=SR):
    os.makedirs(OUT, exist_ok=True)
    data = (np.clip(x, -1, 1) * 32767).astype('<i2')
    with wave.open(os.path.join(OUT, name + '.wav'), 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sr)
        w.writeframes(data.tobytes())
    print(f'{name}.wav  {len(x) / sr:.2f}s')


def main():
    # Placing a block: three slightly different pitches, picked at random in-game.
    for i, ratio in enumerate([1.0, 1.04, 0.96]):
        write(f'place_{i}', finish(reverb(wood(330 * ratio), 0.6, 0.12), 0.55))

    # Picking a block up: a barely-there tick.
    t = t_axis(0.05)
    tick = np.sin(2 * np.pi * 1400 * t) * np.exp(-t / 0.008)
    write('pickup', finish(tick, 0.18))

    # Dropping where it doesn't fit: soft low bump, never a harsh buzzer.
    t = t_axis(0.14)
    bump = np.sin(2 * np.pi * 150 * t * (1 - 0.3 * t)) * np.exp(-t / 0.04)
    write('invalid', finish(lowpass(bump, 900), 0.35))

    # Line clear, one file per combo level: 3-note pentatonic arpeggio that
    # climbs one scale step each level, with a warm octave-down body note.
    for level in range(1, 9):
        i = 5 + level - 1  # starts at C5
        notes = [penta(i), penta(i + 2), penta(i + 4)]
        events = [(0.0, 0.25 * bell(notes[0] / 2, 1.0, 0.3))]
        events += [(k * 0.055, bell(f, 1.3)) for k, f in enumerate(notes)]
        write(f'clear_{level}', finish(reverb(place_notes(events, 1.6), 1.6, 0.3), 0.8))

    # Extra sparkle layered on top when 2+ lines clear at once.
    events = [(k * 0.032, 0.6 * bell(penta(12 + (k % 5) + k // 5 * 2), 0.7, 1.4))
              for k in range(7)]
    write('sparkle', finish(reverb(place_notes(events, 1.0), 1.4, 0.35), 0.45))

    # Board completely cleared: a glissando up the scale into a held chord.
    events = [(k * 0.045, 0.7 * bell(penta(5 + k), 0.9)) for k in range(10)]
    events += [(0.48, 0.8 * bell(f, 2.2)) for f in (penta(10), penta(12), penta(13), penta(14))]
    write('perfect', finish(reverb(place_notes(events, 3.0), 2.2, 0.35), 0.85))

    # Game over: a gentle descending phrase, low-passed and quiet. Calm, not sad.
    events = [(k * 0.24, bell(f, 1.8, 0.4)) for k, f in enumerate([penta(9), penta(7), penta(5)])]
    write('gameover', finish(reverb(lowpass(place_notes(events, 2.8), 2200), 2.2, 0.4), 0.55))

    # Revive: rising shimmer.
    events = [(k * 0.05, 0.7 * bell(penta(5 + k * 2), 1.0)) for k in range(5)]
    write('revive', finish(reverb(place_notes(events, 1.8), 1.8, 0.35), 0.7))

    # Coins: two bright bell taps.
    events = [(0.0, bell(penta(13), 0.6, 1.3)), (0.07, bell(penta(15), 0.8, 1.3))]
    write('coin', finish(reverb(place_notes(events, 1.0), 1.0, 0.2), 0.5))

    # Level up / reward claimed: major arpeggio + chord.
    events = [(k * 0.08, bell(penta(i), 1.2)) for k, i in enumerate([5, 7, 8, 10])]
    events += [(0.36, 0.6 * bell(f, 1.8)) for f in (penta(10), penta(12), penta(13))]
    write('levelup', finish(reverb(place_notes(events, 2.4), 1.8, 0.3), 0.75))

    # UI tap: soft pop.
    t = t_axis(0.07)
    f = 620 - 220 * (1 - np.exp(-t / 0.01))
    pop = np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t / 0.018)
    write('tap', finish(pop, 0.3))

    music()


def pad_note(freq, seconds, sr):
    t = t_axis(seconds, sr)
    sig = np.zeros_like(t)
    for detune in (-0.0018, 0.0, 0.0021):  # gentle chorus
        f = freq * (1 + detune)
        sig += np.sin(2 * np.pi * f * t) + 0.18 * np.sin(4 * np.pi * f * t)
    attack, release = 2.2, 2.6
    env = np.minimum(1, t / attack) * np.minimum(1, (seconds - t) / release).clip(0)
    trem = 1 + 0.06 * np.sin(2 * np.pi * 0.17 * t + freq)
    return sig * env * trem / 3


def music():
    """32-second seamless ambient loop: four soft pad chords + sparse bells."""
    sr = MUSIC_SR
    bar = 8.0
    midi = lambda m: 440.0 * 2 ** ((m - 69) / 12)
    chords = [
        [48, 55, 59, 62, 64],  # Cmaj9
        [45, 52, 55, 59, 60],  # Am9
        [41, 48, 52, 55, 57],  # Fmaj9
        [43, 50, 52, 57, 60],  # G6/9 sus
    ]
    length = bar * len(chords)
    tail = 8.0
    out = np.zeros(int((length + tail) * sr))
    for c, notes in enumerate(chords):
        for m in notes:
            sig = 0.16 * pad_note(midi(m), bar + 2.0, sr)
            i = int(c * bar * sr)
            out[i:i + len(sig)] += sig[: len(out) - i]

    r = np.random.default_rng(11)
    t = 1.0
    while t < length - 1:
        f = penta(int(r.integers(5, 13)))
        sig = 0.22 * bell(f, 2.5, 0.5, sr)
        i = int(t * sr)
        out[i:i + len(sig)] += sig[: len(out) - i]
        t += float(r.choice([2.0, 3.0, 4.0]))

    out = lowpass(out, 3000, sr)
    out = reverb(out, 3.5, 0.45, sr, seed=5)
    # Fold the tail back onto the start so the loop is seamless.
    loop = out[: int(length * sr)].copy()
    rest = out[int(length * sr):]
    loop[: len(rest)] += rest[: len(loop)]
    loop = loop - np.mean(loop)
    loop = loop / np.max(np.abs(loop)) * 0.5
    write('music_loop', loop, sr)


if __name__ == '__main__':
    main()
