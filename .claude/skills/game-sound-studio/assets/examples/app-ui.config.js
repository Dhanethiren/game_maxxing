/*
 * Example sound config: a friendly app (not a game). Short, quiet UI sounds
 * that confirm actions without getting tiring: tap, toggle, success, error,
 * notification, send and delete. Major scale, plucks and soft blips.
 */
(function (root, factory) {
  if (typeof module === 'object' && module.exports) module.exports = factory;
  else root.SoundConfig = factory;
})(typeof self !== 'undefined' ? self : this, function (core) {
  'use strict';
  const { blip, bell, pluck, noiseHit, bandpass, warm, reverb, finish, sequence, mixInto, silence } = core;

  // Shared ending: a little room, then peak-normalise and trim.
  function done(y, p, g, sr, tail) {
    return finish(reverb(y, { sr, wet: p.reverb || 0, size: g.room, tail: tail || 0.5 }), p.volume, sr);
  }

  return {
    title: 'Pocket App',
    subtitle: 'Interface sounds for the app: short, soft and consistent.',
    outDir: '../../assets/sounds',
    scale: { root: 72, steps: core.SCALES.major },
    global: {
      transpose: [0, -6, 6, 1, 'semitones', 'Key'],
      brightness: [1, 0.5, 1.6, 0.05, '×', 'Overall brightness'],
      room: [0.7, 0.5, 0.92, 0.01, '', 'Room size'],
    },
    preview: ['success', 0],
    sounds: [
      {
        key: 'tap',
        name: 'Tap',
        group: 'Touch',
        when: 'Any button press.',
        files: ['ui_tap'],
        params: {
          pitch: [880, 300, 2000, 10, 'Hz', 'Tone'],
          drop: [35, 0, 70, 1, '%', 'Pitch drop'],
          length: [14, 4, 50, 1, 'ms', 'Length'],
          volume: [0.35, 0.05, 0.9, 0.01, '', 'Loudness'],
          gameVolume: [0.6, 0, 1, 0.05, '', 'In-app volume'],
        },
        render(p, g, x) {
          const y = blip({ freq: p.pitch, freqEnd: p.pitch * (1 - p.drop / 100), glide: p.length / 2000, dur: (p.length / 1000) * 5, decay: p.length / 1000, sr: x.sr });
          return finish(warm(y, 4000 * g.brightness, x.sr), p.volume, x.sr);
        },
      },
      {
        key: 'toggle',
        name: 'Toggle',
        group: 'Touch',
        when: 'A switch turns on (rising pair) or off (falling pair).',
        files: ['ui_toggle_on', 'ui_toggle_off'],
        chipLabels: ['On', 'Off'],
        params: {
          note: [2, 0, 7, 1, 'note', 'Note'],
          interval: [2, 1, 4, 1, 'count', 'Interval (scale steps)'],
          gap: [45, 15, 120, 1, 'ms', 'Gap'],
          length: [25, 8, 80, 1, 'ms', 'Note length'],
          volume: [0.35, 0.05, 0.9, 0.01, '', 'Loudness'],
          gameVolume: [0.6, 0, 1, 0.05, '', 'In-app volume'],
        },
        render(p, g, x) {
          const up = x.index === 0;
          const a = x.hz(p.note + (up ? 0 : p.interval));
          const b = x.hz(p.note + (up ? p.interval : 0));
          const d = p.length / 1000;
          const note = function (f) { return blip({ freq: f, dur: d * 5, decay: d, shape: 'triangle', sr: x.sr }); };
          const y = sequence([[0, note(a), 0.8], [p.gap / 1000, note(b), 1]], p.gap / 1000 + d * 5, x.sr);
          return finish(warm(y, 3500 * g.brightness, x.sr), p.volume, x.sr);
        },
      },
      {
        key: 'success',
        name: 'Success',
        group: 'Feedback',
        when: 'A task completes: saved, sent, purchase done.',
        files: ['ui_success'],
        params: {
          note: [0, -3, 7, 1, 'note', 'First note'],
          gap: [70, 30, 160, 1, 'ms', 'Gap'],
          ring: [0.6, 0.2, 1.6, 0.05, 's', 'Ring length'],
          brightness: [0.8, 0.2, 2, 0.05, '×', 'Brightness'],
          reverb: [0.2, 0, 0.6, 0.01, '', 'Echo'],
          volume: [0.6, 0.1, 0.9, 0.01, '', 'Loudness'],
          gameVolume: [0.9, 0, 1, 0.05, '', 'In-app volume'],
        },
        render(p, g, x) {
          const sr = x.sr;
          const br = p.brightness * g.brightness;
          const gap = p.gap / 1000;
          const y = sequence([
            [0, bell(x.hz(p.note), p.ring, br, sr), 0.8],
            [gap, bell(x.hz(p.note + 2), p.ring, br, sr), 0.8],
            [gap * 2, bell(x.hz(p.note + 4), p.ring * 1.4, br, sr), 1],
          ], gap * 2 + p.ring * 1.4, sr);
          return done(y, p, g, sr, 1);
        },
      },
      {
        key: 'error',
        name: 'Error',
        group: 'Feedback',
        when: 'Something failed or input is invalid. Noticeable, never alarming.',
        files: ['ui_error'],
        params: {
          pitch: [260, 120, 500, 5, 'Hz', 'Tone'],
          gap: [90, 40, 200, 1, 'ms', 'Gap'],
          length: [60, 20, 150, 1, 'ms', 'Note length'],
          softness: [1400, 500, 4000, 50, 'Hz', 'Softness (lower = softer)'],
          volume: [0.45, 0.05, 0.9, 0.01, '', 'Loudness'],
          gameVolume: [0.8, 0, 1, 0.05, '', 'In-app volume'],
        },
        // Two soft triangle notes, the second a semitone lower: a gentle "uh-uh".
        render(p, g, x) {
          const d = p.length / 1000;
          const note = function (f) { return blip({ freq: f, freqEnd: f * 0.97, dur: d * 3, decay: d, shape: 'triangle', sr: x.sr }); };
          const y = sequence([[0, note(p.pitch), 1], [p.gap / 1000, note(p.pitch * 0.944), 1]], p.gap / 1000 + d * 3, x.sr);
          return finish(warm(y, p.softness * g.brightness, x.sr), p.volume, x.sr);
        },
      },
      {
        key: 'notify',
        name: 'Notification',
        group: 'Feedback',
        when: 'A new message or reminder arrives while the app is open.',
        files: ['ui_notify'],
        params: {
          note: [4, 0, 9, 1, 'note', 'Top note'],
          gap: [80, 30, 200, 1, 'ms', 'Gap'],
          ring: [0.9, 0.3, 2, 0.05, 's', 'Ring length'],
          pluckiness: [0.45, 0.1, 0.9, 0.01, '', 'Pluck softness'],
          reverb: [0.25, 0, 0.6, 0.01, '', 'Echo'],
          volume: [0.6, 0.1, 0.9, 0.01, '', 'Loudness'],
          gameVolume: [0.9, 0, 1, 0.05, '', 'In-app volume'],
        },
        render(p, g, x) {
          const sr = x.sr;
          const opts = { decay: 0.997, blend: p.pluckiness };
          const y = sequence([
            [0, pluck(x.hz(p.note - 4), p.ring, sr, opts), 0.8],
            [p.gap / 1000, pluck(x.hz(p.note), p.ring, sr, opts), 1],
          ], p.gap / 1000 + p.ring, sr);
          return done(warm(y, 5000 * g.brightness, sr), p, g, sr, 1);
        },
      },
      {
        key: 'send',
        name: 'Send',
        group: 'Actions',
        when: 'A message or file is sent: a short rising whoosh.',
        files: ['ui_send'],
        params: {
          length: [0.22, 0.08, 0.6, 0.01, 's', 'Length'],
          low: [600, 150, 2000, 10, 'Hz', 'Low edge'],
          high: [3200, 1200, 8000, 50, 'Hz', 'High edge'],
          volume: [0.4, 0.05, 0.9, 0.01, '', 'Loudness'],
          gameVolume: [0.7, 0, 1, 0.05, '', 'In-app volume'],
        },
        render(p, g, x) {
          const sr = x.sr;
          const y = bandpass(core.noise(p.length + 0.05, sr, 9), p.low, p.high * g.brightness, sr);
          for (let i = 0; i < y.length; i++) {
            const t = i / sr / p.length;
            y[i] *= t < 1 ? Math.pow(t, 1.5) * (1 - t) * 3 : 0; // rises, then cuts off
          }
          return finish(y, p.volume, sr);
        },
      },
      {
        key: 'delete',
        name: 'Delete',
        group: 'Actions',
        when: 'An item is deleted or dismissed: a soft papery tuck.',
        files: ['ui_delete'],
        params: {
          length: [0.08, 0.03, 0.25, 0.005, 's', 'Length'],
          tone: [1800, 400, 5000, 50, 'Hz', 'Brightness'],
          thump: [0.3, 0, 1, 0.05, '', 'Low thump'],
          volume: [0.4, 0.05, 0.9, 0.01, '', 'Loudness'],
          gameVolume: [0.7, 0, 1, 0.05, '', 'In-app volume'],
        },
        render(p, g, x) {
          const sr = x.sr;
          const out = silence(p.length * 4, sr);
          mixInto(out, noiseHit({ dur: p.length * 3, decay: p.length / 2, low: 300, high: p.tone * g.brightness, sr, seed: 4 }), 0, sr, 1);
          mixInto(out, blip({ freq: 180, freqEnd: 120, dur: p.length * 3, decay: p.length / 2, sr }), 0, sr, p.thump);
          return finish(out, p.volume, sr);
        },
      },
    ],
    scenarios: [
      { name: 'Fill a form', desc: 'Taps, a toggle, then success', events: [[0, 'tap'], [300, 'tap'], [650, 'toggle', 0], [1200, 'tap'], [1400, 'success']] },
      { name: 'Oops, then fixed', desc: 'Error, then success', events: [[0, 'tap'], [150, 'error'], [1100, 'tap'], [1250, 'success']] },
      { name: 'Chat', desc: 'Send, then a reply arrives', events: [[0, 'send'], [1300, 'notify']] },
      { name: 'Tidy up', desc: 'Delete three items', events: [[0, 'delete'], [380, 'delete'], [760, 'delete']] },
    ],
  };
});
