"""Regenerate Foxtopia's original, synthesized PCM audio assets.

Uses only Python's standard library. Run from any directory; output paths are
relative to this file. The generated WAVs are committed with the game so a
player does not wait for synthesis when launching it.
"""

from array import array
import math
from pathlib import Path
import random
import wave


RATE = 22050
TAU = math.tau
OUT = Path(__file__).resolve().parents[2] / "assets" / "audio"


def hz(midi: int) -> float:
    return 440.0 * 2.0 ** ((midi - 69) / 12.0)


def buffer(seconds: float) -> array:
    return array("f", [0.0]) * round(seconds * RATE)


def add_pad(samples: array, start: float, duration: float, notes: tuple[int, ...], gain: float) -> None:
    first = round(start * RATE)
    count = min(round(duration * RATE), len(samples) - first)
    for note in notes:
        frequency = hz(note)
        for i in range(count):
            t = i / RATE
            attack = min(1.0, t / 0.33)
            release = min(1.0, (duration - t) / 0.47)
            envelope = max(0.0, attack * release)
            phase = TAU * frequency * t
            # A little second harmonic keeps the pad warm without hiding UI sounds.
            samples[first + i] += gain * envelope * (
                math.sin(phase) + 0.16 * math.sin(2.01 * phase)
            )


def add_pluck(samples: array, start: float, note: int, gain: float, duration: float = 1.7) -> None:
    first = round(start * RATE)
    count = min(round(duration * RATE), len(samples) - first)
    frequency = hz(note)
    for i in range(count):
        t = i / RATE
        attack = min(1.0, t / 0.012)
        envelope = attack * math.exp(-2.7 * t)
        phase = TAU * frequency * t
        samples[first + i] += gain * envelope * (
            math.sin(phase) + 0.24 * math.sin(2.0 * phase)
            + 0.10 * math.sin(3.0 * phase)
        )


def add_bass(samples: array, start: float, note: int, gain: float) -> None:
    first = round(start * RATE)
    count = min(round(2.2 * RATE), len(samples) - first)
    frequency = hz(note)
    for i in range(count):
        t = i / RATE
        envelope = min(1.0, t / 0.035) * math.exp(-1.2 * t)
        samples[first + i] += gain * envelope * math.sin(TAU * frequency * t)


def make_theme(chords: tuple[tuple[int, ...], ...], melody: tuple[int, ...],
               bass: tuple[int, ...], melody_step: float, pad_gain: float) -> array:
    length = 24.0
    samples = buffer(length)
    for bar, notes in enumerate(chords):
        add_pad(samples, bar * 6.0, 6.0, notes, pad_gain)
        add_bass(samples, bar * 6.0 + 0.04, bass[bar], 0.20)
        add_bass(samples, bar * 6.0 + 3.0, bass[bar] + 7, 0.12)
    for i, note in enumerate(melody):
        if note >= 0:
            add_pluck(samples, i * melody_step + 0.15, note, 0.15)
    # The loop's endpoints return to silence smoothly.
    fade = round(0.30 * RATE)
    for i in range(fade):
        factor = i / fade
        samples[i] *= factor
        samples[-i - 1] *= factor
    return samples


def effect(kind: str) -> array:
    duration = {
        "ui_click": 0.14, "ui_select": 0.30, "order": 0.24,
        "build": 0.65, "research": 0.95, "alert": 1.05,
        "trade": 0.50, "reject": 0.34,
    }[kind]
    samples = buffer(duration)
    rng = random.Random(518 + len(kind))
    filtered_noise = 0.0
    for i in range(len(samples)):
        t = i / RATE
        if kind == "ui_click":
            envelope = (1.0 - math.exp(-t * 420.0)) * math.exp(-t * 34.0)
            phase = TAU * (540.0 * t - 60.0 * t * t)
            value = 0.56 * envelope * (math.sin(phase) + 0.22 * math.sin(2.0 * phase))
        elif kind == "ui_select":
            envelope = (1.0 - math.exp(-t * 160.0)) * math.exp(-t * 13.0)
            value = 0.43 * envelope * (math.sin(TAU * 587.33 * t)
                                       + 0.45 * math.sin(TAU * 783.99 * t))
        elif kind == "order":
            filtered_noise = 0.72 * filtered_noise + 0.28 * rng.uniform(-1.0, 1.0)
            envelope = (1.0 - math.exp(-t * 550.0)) * math.exp(-t * 25.0)
            value = envelope * (0.37 * math.sin(TAU * 190.0 * t) + 0.24 * filtered_noise)
        elif kind == "build":
            envelope = (1.0 - math.exp(-t * 95.0)) * math.exp(-t * 5.3)
            value = 0.36 * envelope * (math.sin(TAU * 392.0 * t)
                                       + 0.6 * math.sin(TAU * 587.33 * t))
        elif kind == "research":
            value = 0.0
            for onset, note in ((0.0, 72), (0.17, 76), (0.34, 79)):
                if t >= onset:
                    u = t - onset
                    env = (1.0 - math.exp(-u * 130.0)) * math.exp(-u * 6.0)
                    value += 0.28 * env * (math.sin(TAU * hz(note) * u)
                                            + 0.22 * math.sin(TAU * hz(note) * 2.0 * u))
        elif kind == "alert":
            envelope = (1.0 - math.exp(-t * 30.0)) * math.exp(-t * 2.3)
            value = 0.40 * envelope * (math.sin(TAU * 196.0 * t)
                                       + 0.65 * math.sin(TAU * 207.65 * t))
        elif kind == "reject":
            # A short falling two-tone cue for a command that cannot run.
            envelope = (1.0 - math.exp(-t * 220.0)) * math.exp(-t * 11.0)
            frequency = 440.0 - 250.0 * min(1.0, t / 0.30)
            phase = TAU * (440.0 * t - 125.0 * t * t / 0.30)
            value = 0.30 * envelope * (math.sin(phase) + 0.25 * math.sin(TAU * frequency * t))
        else:  # trade: two bright, restrained coin tones.
            value = 0.0
            for onset, note in ((0.0, 83), (0.11, 88)):
                if t >= onset:
                    u = t - onset
                    env = (1.0 - math.exp(-u * 210.0)) * math.exp(-u * 13.0)
                    value += 0.27 * env * (math.sin(TAU * hz(note) * u)
                                            + 0.30 * math.sin(TAU * hz(note) * 2.7 * u))
        samples[i] = value
    return samples


def write(name: str, samples: array) -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    peak = max(abs(value) for value in samples)
    if peak > 0.94:
        scale = 0.94 / peak
    else:
        scale = 1.0
    pcm = array("h", (round(max(-1.0, min(1.0, value * scale)) * 32767)
                      for value in samples))
    with wave.open(str(OUT / name), "wb") as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(RATE)
        wav.writeframes(pcm.tobytes())
    rms = math.sqrt(sum(value * value for value in samples) / len(samples))
    print(f"{name}: {len(samples) / RATE:.2f}s, peak={peak:.3f}, rms={rms:.3f}")


if __name__ == "__main__":
    write("menu_theme.wav", make_theme(
        ((50, 53, 57, 64), (46, 50, 53, 57), (53, 57, 60, 64), (48, 55, 62, 64)),
        (69, 72, 74, 72, 69, 65, 69, 72, 74, 77, 76, 72,
         69, 72, 76, 74, 72, 69, 67, 69, 72, 74, 69, 65),
        (38, 34, 41, 36), 1.0, 0.058))
    write("colony_theme.wav", make_theme(
        ((45, 52, 57, 60), (41, 48, 52, 57), (48, 52, 55, 59), (43, 50, 55, 57)),
        (72, -1, 76, -1, 74, -1, 72, -1, 69, -1, 72, -1,
         76, -1, 79, -1, 76, -1, 72, -1, 74, -1, 69, -1),
        (33, 29, 36, 31), 1.0, 0.050))
    for name in ("ui_click", "ui_select", "order", "build", "research", "alert", "trade", "reject"):
        write(name + ".wav", effect(name))
