#!/usr/bin/env node
/*
 * Renders every sound in a sounds config to WAV files.
 *
 *   node render.js                              # ./sounds.config.js next to this script
 *   node render.js --config path/sounds.config.js --out assets/sounds
 *   node render.js --settings saved.json        # apply studio settings (also saved)
 *   node render.js --defaults                   # ignore settings.json, use config defaults
 *   node render.js --only clear,coin            # just these sounds
 *
 * Settings, in order of preference: --settings file (a studio save or a plain
 * settings object), else settings.json next to the config (the project's
 * current tuned design), else the config defaults. Whatever is used is written
 * back to settings.json so the design stays versioned with the project.
 *
 * Output: <out>/<file>.wav for every file, plus <out>/mix.json: the in-game
 * volume multiplier per file name (each sound's gameVolume param).
 */
'use strict';
const fs = require('fs');
const path = require('path');

function parseArgs(argv) {
  const a = { config: null, out: null, settings: null, defaults: false, only: null, writeSettings: true };
  for (let i = 0; i < argv.length; i++) {
    const k = argv[i];
    const next = function () {
      if (i + 1 >= argv.length) throw new Error(k + ' needs a value');
      return argv[++i];
    };
    if (k === '--config') a.config = next();
    else if (k === '--out') a.out = next();
    else if (k === '--settings') a.settings = next();
    else if (k === '--defaults') a.defaults = true;
    else if (k === '--only') a.only = next().split(',').map(function (s) { return s.trim(); });
    else if (k === '--no-save-settings') a.writeSettings = false;
    else if (k === '-h' || k === '--help') { a.help = true; }
    else if (!k.startsWith('--') && !a.settings) a.settings = k; // positional = settings file
    else throw new Error('unknown option ' + k);
  }
  return a;
}

function findCore() {
  for (const p of [path.join(__dirname, 'synth_core.js')]) if (fs.existsSync(p)) return require(p);
  throw new Error('synth_core.js must sit next to render.js');
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) {
    console.log(fs.readFileSync(__filename, 'utf8').split('*/')[0]);
    return;
  }
  const core = findCore();
  const configPath = path.resolve(args.config || path.join(__dirname, 'sounds.config.js'));
  if (!fs.existsSync(configPath)) throw new Error('no config at ' + configPath + ' (use --config)');
  const configDir = path.dirname(configPath);
  const config = require(configPath)(core);
  const engine = core.createEngine(config);

  const outDir = path.resolve(args.out || (config.outDir ? path.join(configDir, config.outDir) : path.join(configDir, 'out')));
  const storedPath = path.join(configDir, 'settings.json');

  let source = 'config defaults';
  let raw = null;
  if (args.settings) {
    raw = JSON.parse(fs.readFileSync(args.settings, 'utf8'));
    source = args.settings;
  } else if (!args.defaults && fs.existsSync(storedPath)) {
    raw = JSON.parse(fs.readFileSync(storedPath, 'utf8'));
    source = path.relative(process.cwd(), storedPath);
  }
  if (raw && raw.note) console.log('Note saved with these settings: "' + raw.note + '"');
  const settings = engine.normalize(raw);

  fs.mkdirSync(outDir, { recursive: true });
  console.log('Settings from', source);
  let count = 0;
  for (const snd of engine.CATALOGUE) {
    if (args.only && args.only.indexOf(snd.key) < 0) continue;
    snd.files.forEach(function (file, i) {
      const t0 = Date.now();
      const r = engine.render(snd.key, settings, i);
      let peak = 0;
      for (let k = 0; k < r.samples.length; k++) peak = Math.max(peak, Math.abs(r.samples[k]));
      fs.writeFileSync(path.join(outDir, file + '.wav'), engine.wav(r.samples, r.sampleRate));
      const secs = (r.samples.length / r.sampleRate).toFixed(2);
      const warn = peak > 0.95 ? '  <- peak ' + peak.toFixed(2) + ', lower its volume' : '';
      console.log('  ' + file.padEnd(16), (secs + 's').padStart(7), String(r.sampleRate).padStart(6) + ' Hz', '(' + (Date.now() - t0) + ' ms)' + warn);
      count++;
    });
  }
  // mix.json always covers every file, even with --only.
  fs.writeFileSync(path.join(outDir, 'mix.json'), JSON.stringify(engine.mix(settings), null, 2) + '\n');
  if (args.writeSettings) fs.writeFileSync(storedPath, JSON.stringify(settings, null, 2) + '\n');
  console.log('Wrote', count, 'files and mix.json to', path.relative(process.cwd(), outDir) || '.');
}

try {
  main();
} catch (e) {
  console.error(String(e && e.message ? e.message : e));
  process.exit(1);
}
