#!/usr/bin/env node
/*
 * Builds the Sound Studio page for a sounds config: one self-contained HTML
 * file with the core engine and the config inlined, so the page plays exactly
 * what render.js writes.
 *
 *   node build_studio.js                         # ./sounds.config.js -> ./studio.html
 *   node build_studio.js --config path/sounds.config.js --out /tmp/studio.html
 *
 * If settings.json sits next to the config (the project's current design),
 * it is embedded as the page's starting point and its "reset" target.
 */
'use strict';
const fs = require('fs');
const path = require('path');

function arg(name) {
  const i = process.argv.indexOf(name);
  return i > 0 ? process.argv[i + 1] : null;
}

function firstExisting(paths, what) {
  for (const p of paths) if (fs.existsSync(p)) return p;
  throw new Error('cannot find ' + what + ' (looked in ' + paths.join(', ') + ')');
}

function esc(s) {
  return String(s).replace(/[&<>"]/g, function (c) {
    return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c];
  });
}

function cssColor(v) {
  return typeof v === 'string' && /^(#[0-9a-fA-F]{3,8}|[a-z]+|rgba?\([0-9.,\s%]+\)|hsla?\([0-9.,\s%deg]+\))$/.test(v.trim()) ? v.trim() : null;
}

function themeCss(theme) {
  if (!theme) return '';
  const light = [];
  const dark = [];
  const a = cssColor(theme.accent);
  const ad = cssColor(theme.accentDark);
  if (a) light.push('--accent: ' + a + ';', '--wave: ' + a + ';');
  if (ad) dark.push('--accent: ' + ad + ';', '--wave: ' + ad + ';');
  let css = '';
  if (light.length) css += ':root { ' + light.join(' ') + ' }\n';
  if (dark.length) {
    css += '@media (prefers-color-scheme: dark) { :root:not([data-theme="light"]) { ' + dark.join(' ') + ' } }\n';
    css += ':root[data-theme="dark"] { ' + dark.join(' ') + ' }\n';
  }
  return css;
}

function main() {
  const configPath = path.resolve(arg('--config') || path.join(__dirname, 'sounds.config.js'));
  const configDir = path.dirname(configPath);
  const out = path.resolve(arg('--out') || path.join(configDir, 'studio.html'));
  const corePath = firstExisting([path.join(__dirname, 'synth_core.js')], 'synth_core.js');
  const tplPath = firstExisting(
    [path.join(__dirname, 'studio.template.html'), path.join(__dirname, '..', 'assets', 'studio.template.html')],
    'studio.template.html'
  );

  const core = require(corePath);
  const config = require(configPath)(core);
  const engine = core.createEngine(config); // validates the config

  const coreSrc = fs.readFileSync(corePath, 'utf8');
  const configSrc = fs.readFileSync(configPath, 'utf8');
  for (const [name, src] of [['synth_core.js', coreSrc], [path.basename(configPath), configSrc]]) {
    if (/<\/script/i.test(src)) throw new Error(name + ' must not contain "</script"');
  }

  const settingsPath = arg('--settings') || path.join(configDir, 'settings.json');
  let current = 'null';
  if (fs.existsSync(settingsPath)) {
    current = JSON.stringify(engine.normalize(JSON.parse(fs.readFileSync(settingsPath, 'utf8'))));
  }

  const title = engine.TITLE;
  const slug = title.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '') || 'game';
  const subtitle = config.subtitle || 'Listen to every sound, move the sliders, and hear the change straight away.';

  const html = fs
    .readFileSync(tplPath, 'utf8')
    .split('{{TITLE}}').join(esc(title))
    .split('{{SUBTITLE}}').join(esc(subtitle))
    .replace('/*THEME*/', function () { return themeCss(config.theme); })
    .replace('/*CORE*/', function () { return coreSrc; })
    .replace('/*CONFIG*/', function () { return configSrc; })
    .replace("/*SLUG*/'game'", function () { return JSON.stringify(slug); })
    .replace('/*BUILT_AT*/0', function () { return String(Date.now()); })
    .replace('/*CURRENT*/null', function () { return current; });

  fs.mkdirSync(path.dirname(out), { recursive: true });
  fs.writeFileSync(out, html);
  const files = engine.CATALOGUE.reduce(function (n, s) { return n + s.files.length; }, 0);
  console.log('Wrote', out, '(' + (fs.statSync(out).size / 1024).toFixed(1) + ' KB,', engine.CATALOGUE.length, 'sounds,', files, 'files' + (current !== 'null' ? ', with current settings' : '') + ')');
}

try {
  main();
} catch (e) {
  console.error(String(e && e.message ? e.message : e));
  process.exit(1);
}
