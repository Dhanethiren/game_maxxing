#!/usr/bin/env node
/*
 * Writes every game sound from Sound Studio settings.
 *
 *   node tool/sound/render.js                 # default settings
 *   node tool/sound/render.js my-settings.json
 *
 * Output: assets/sounds/*.wav and assets/sounds/mix.json (the in-game volume
 * of each file, read by lib/audio/sound_service.dart). The settings JSON is
 * what the Sound Studio page saves; it is also copied to
 * tool/sound/settings.json so the current sound design is versioned.
 */
'use strict';
const fs = require('fs');
const path = require('path');
const synth = require('./synth.js');

const root = path.join(__dirname, '..', '..');
const outDir = path.join(root, 'assets', 'sounds');
const arg = process.argv[2];
const settings = synth.normalize(arg ? JSON.parse(fs.readFileSync(arg, 'utf8')) : null);

fs.mkdirSync(outDir, { recursive: true });
for (const snd of synth.CATALOGUE) {
  snd.files.forEach(function (file, i) {
    const t0 = Date.now();
    const r = synth.render(snd.key, settings, i);
    fs.writeFileSync(path.join(outDir, file + '.wav'), synth.wav(r.samples, r.sampleRate));
    const secs = (r.samples.length / r.sampleRate).toFixed(2);
    console.log(file.padEnd(12), secs + 's', '(' + (Date.now() - t0) + ' ms)');
  });
}
fs.writeFileSync(path.join(outDir, 'mix.json'), JSON.stringify(synth.mix(settings), null, 2) + '\n');
fs.writeFileSync(path.join(__dirname, 'settings.json'), JSON.stringify(settings, null, 2) + '\n');
console.log('Wrote', outDir, 'and mix.json');
