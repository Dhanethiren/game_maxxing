#!/usr/bin/env node
/*
 * Checks sound files for the problems that make game audio feel cheap:
 * clipping, no headroom, a delay before the sound starts, DC offset, files
 * far too quiet, harsh brightness on short repeated sounds and loop seams.
 *
 *   node analyze.js assets/sounds                 # every .wav in a folder
 *   node analyze.js a.wav b.wav --loop music.wav  # treat music.wav as a loop
 *   node analyze.js assets/sounds --config tool/sound/sounds.config.js
 *   node analyze.js assets/sounds --json          # machine-readable
 *
 * With --config, sounds marked `loop: true` are checked as loops, and the
 * mix.json volumes are taken into account for the loudness comparison.
 * Reads 16/24/32-bit PCM and 32-bit float WAV, mono or stereo.
 * Exit code 1 when a file is unreadable or clips.
 */
'use strict';
const fs = require('fs');
const path = require('path');

function readWav(file) {
  const b = fs.readFileSync(file);
  if (b.toString('ascii', 0, 4) !== 'RIFF' || b.toString('ascii', 8, 12) !== 'WAVE') throw new Error('not a RIFF/WAVE file');
  let off = 12;
  let fmt = null;
  let data = null;
  while (off + 8 <= b.length) {
    const id = b.toString('ascii', off, off + 4);
    const size = b.readUInt32LE(off + 4);
    const body = off + 8;
    if (id === 'fmt ') {
      fmt = {
        format: b.readUInt16LE(body),
        channels: b.readUInt16LE(body + 2),
        sampleRate: b.readUInt32LE(body + 4),
        bits: b.readUInt16LE(body + 14),
      };
      if (fmt.format === 0xfffe && size >= 26) fmt.format = b.readUInt16LE(body + 24);
    } else if (id === 'data') {
      data = b.subarray(body, Math.min(b.length, body + size));
    }
    off = body + size + (size % 2);
  }
  if (!fmt || !data) throw new Error('missing fmt or data chunk');
  const bytes = fmt.bits / 8;
  const frame = bytes * fmt.channels;
  const n = Math.floor(data.length / frame);
  const out = new Float32Array(n);
  for (let i = 0; i < n; i++) {
    let sum = 0;
    for (let c = 0; c < fmt.channels; c++) {
      const p = i * frame + c * bytes;
      let v;
      if (fmt.format === 3 && fmt.bits === 32) v = data.readFloatLE(p);
      else if (fmt.format === 1 && fmt.bits === 16) v = data.readInt16LE(p) / 32768;
      else if (fmt.format === 1 && fmt.bits === 24) v = data.readIntLE(p, 3) / 8388608;
      else if (fmt.format === 1 && fmt.bits === 32) v = data.readInt32LE(p) / 2147483648;
      else if (fmt.format === 1 && fmt.bits === 8) v = (data.readUInt8(p) - 128) / 128;
      else throw new Error('unsupported WAV format ' + fmt.format + ' / ' + fmt.bits + '-bit');
      sum += v;
    }
    out[i] = sum / fmt.channels;
  }
  return { sampleRate: fmt.sampleRate, channels: fmt.channels, bits: fmt.bits, samples: out };
}

/** In-place radix-2 FFT on re/im arrays (length a power of two). */
function fft(re, im) {
  const n = re.length;
  for (let i = 1, j = 0; i < n; i++) {
    let bit = n >> 1;
    for (; j & bit; bit >>= 1) j ^= bit;
    j ^= bit;
    if (i < j) { let t = re[i]; re[i] = re[j]; re[j] = t; t = im[i]; im[i] = im[j]; im[j] = t; }
  }
  for (let len = 2; len <= n; len <<= 1) {
    const ang = (-2 * Math.PI) / len;
    const wr = Math.cos(ang);
    const wi = Math.sin(ang);
    for (let i = 0; i < n; i += len) {
      let cr = 1;
      let ci = 0;
      for (let k = 0; k < len / 2; k++) {
        const a = i + k;
        const b = a + len / 2;
        const xr = re[b] * cr - im[b] * ci;
        const xi = re[b] * ci + im[b] * cr;
        re[b] = re[a] - xr; im[b] = im[a] - xi;
        re[a] += xr; im[a] += xi;
        const nr = cr * wr - ci * wi;
        ci = cr * wi + ci * wr;
        cr = nr;
      }
    }
  }
}

/** Energy-weighted spectral centroid (Hz): how bright the sound is. */
function centroid(x, sr) {
  const N = 2048;
  const hop = 1024;
  const win = new Float32Array(N);
  for (let i = 0; i < N; i++) win[i] = 0.5 - 0.5 * Math.cos((2 * Math.PI * i) / (N - 1));
  let num = 0;
  let den = 0;
  const re = new Float64Array(N);
  const im = new Float64Array(N);
  const step = Math.max(hop, Math.floor(x.length / 400) * 1); // cap the work on long files
  for (let start = 0; start === 0 || start + N <= x.length; start += step) {
    for (let i = 0; i < N; i++) { re[i] = (x[start + i] || 0) * win[i]; im[i] = 0; }
    fft(re, im);
    for (let k = 1; k < N / 2; k++) {
      const m = re[k] * re[k] + im[k] * im[k];
      num += m * ((k * sr) / N);
      den += m;
    }
    if (start + N >= x.length) break;
  }
  return den > 0 ? num / den : 0;
}

function db(v) {
  return v > 0 ? 20 * Math.log10(v) : -Infinity;
}

function analyze(file, opts) {
  const w = readWav(file);
  const x = w.samples;
  const sr = w.sampleRate;
  let peak = 0;
  let sum = 0;
  let mean = 0;
  for (let i = 0; i < x.length; i++) {
    const a = Math.abs(x[i]);
    if (a > peak) peak = a;
    mean += x[i];
  }
  mean /= x.length || 1;
  const gate = peak * 0.01;
  let first = -1;
  let last = -1;
  for (let i = 0; i < x.length; i++) if (Math.abs(x[i]) > gate) { if (first < 0) first = i; last = i; }
  let active = 0;
  for (let i = Math.max(0, first); i <= last; i++) { sum += x[i] * x[i]; active++; }
  const rms = active ? Math.sqrt(sum / active) : 0;
  let clipped = 0;
  for (let i = 0; i < x.length; i++) if (Math.abs(x[i]) >= 0.999) clipped++;
  // Lead-in: time before the signal rises above -60 dB of its peak. A slow
  // swell is fine; true silence at the start makes the sound feel late.
  let lead = 0;
  while (lead < x.length && Math.abs(x[lead]) <= peak * 0.001) lead++;
  const r = {
    file: path.basename(file),
    sampleRate: sr,
    channels: w.channels,
    bits: w.bits,
    seconds: x.length / sr,
    peakDb: db(peak),
    rmsDb: db(rms),
    leadMs: lead >= x.length ? 0 : (lead / sr) * 1000,
    centroidHz: centroid(x, sr),
    dc: mean,
    clipped: clipped,
    loop: !!opts.loop,
    gameVolume: opts.gameVolume,
    warnings: [],
    errors: [],
  };
  if (opts.loop) {
    // A jump at the seam bigger than almost every step inside the file clicks.
    const diffs = new Float32Array(x.length - 1);
    for (let i = 1; i < x.length; i++) diffs[i - 1] = Math.abs(x[i] - x[i - 1]);
    const sorted = Array.from(diffs).sort(function (a, b) { return a - b; });
    const p999 = sorted[Math.floor(sorted.length * 0.999)] || 0;
    const seam = Math.abs(x[0] - x[x.length - 1]);
    r.seam = seam;
    r.seamLimit = p999;
    if (seam > p999 * 1.5 && seam > 0.01) r.warnings.push('loop seam jump ' + seam.toFixed(3) + ' (inside the file steps stay under ' + p999.toFixed(3) + '): it will click; fold the tail onto the start (core.loopFold)');
    // Compare the level of the opening and closing stretch (up to 1 s): a
    // fade-in or fade-out at the loop point is heard as a dip every cycle.
    const edge = Math.round(sr * Math.min(1, r.seconds * 0.1));
    let headE = 0;
    let tailE = 0;
    for (let i = 0; i < edge && i < x.length; i++) { headE += x[i] * x[i]; tailE += x[x.length - 1 - i] * x[x.length - 1 - i]; }
    if (headE > 0 && tailE > 0) {
      const ratio = db(Math.sqrt(headE / tailE));
      r.edgeDb = ratio;
      if (Math.abs(ratio) > 6) r.warnings.push('loop ' + (ratio > 0 ? 'ends' : 'starts') + ' ' + Math.abs(ratio).toFixed(1) + ' dB quieter than it ' + (ratio > 0 ? 'starts' : 'ends') + ': a fade at the loop point dips every cycle; remove it and fold the tail instead');
    }
  }
  if (clipped > 0) r.errors.push(clipped + ' clipped samples: lower the volume');
  else if (peak > 0.93) r.warnings.push('peak ' + r.peakDb.toFixed(1) + ' dBFS leaves little headroom: overlapping sounds will clip (aim for <= -1 dBFS, about 0.9)');
  if (peak < 0.05) r.warnings.push('very quiet (peak ' + r.peakDb.toFixed(1) + ' dBFS): normalise it and set the level with gameVolume instead');
  if (!opts.loop && r.leadMs > 15) r.warnings.push(r.leadMs.toFixed(0) + ' ms of silence before the sound: it will feel late; trim the start');
  if (Math.abs(mean) > 0.01) r.warnings.push('DC offset ' + mean.toFixed(3) + ': remove it (core.finish does)');
  if (!opts.loop && r.seconds < 0.25 && r.centroidHz > 3500) r.warnings.push('short sound with a bright centre (' + Math.round(r.centroidHz) + ' Hz): if it plays often (taps, ticks), soften it below ~3 kHz to avoid fatigue');
  if (!opts.loop && r.seconds > 6) r.warnings.push(r.seconds.toFixed(1) + ' s is long for a one-shot: is it meant to loop?');
  return r;
}

function main() {
  const argv = process.argv.slice(2);
  const files = [];
  const loops = new Set();
  let config = null;
  let json = false;
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--loop') loops.add(path.basename(argv[++i]));
    else if (a === '--config') config = argv[++i];
    else if (a === '--json') json = true;
    else if (a === '-h' || a === '--help') { console.log(fs.readFileSync(__filename, 'utf8').split('*/')[0]); return 0; }
    else if (fs.existsSync(a) && fs.statSync(a).isDirectory()) {
      fs.readdirSync(a).filter(function (f) { return /\.wav$/i.test(f); }).sort().forEach(function (f) { files.push(path.join(a, f)); });
    } else files.push(a);
  }
  if (!files.length) { console.error('no .wav files given'); return 1; }

  let mix = {};
  if (config) {
    const core = require(path.join(__dirname, 'synth_core.js'));
    const cfg = require(path.resolve(config))(core);
    cfg.sounds.forEach(function (s) { if (s.loop) s.files.forEach(function (f) { loops.add(f + '.wav'); }); });
  }
  const dirs = new Set(files.map(function (f) { return path.dirname(f); }));
  dirs.forEach(function (d) {
    const m = path.join(d, 'mix.json');
    if (fs.existsSync(m)) { try { Object.assign(mix, JSON.parse(fs.readFileSync(m, 'utf8'))); } catch (e) { /* ignore */ } }
  });

  const results = [];
  let failed = false;
  for (const f of files) {
    const base = path.basename(f);
    try {
      const r = analyze(f, { loop: loops.has(base) || /loop/i.test(base), gameVolume: mix[base.replace(/\.wav$/i, '')] });
      if (r.errors.length) failed = true;
      results.push(r);
    } catch (e) {
      failed = true;
      results.push({ file: base, errors: [String(e.message || e)], warnings: [] });
    }
  }

  if (json) {
    console.log(JSON.stringify(results, null, 2));
    return failed ? 1 : 0;
  }
  const head = ['file', 'secs', 'rate', 'peak dB', 'rms dB', 'in-game', 'lead ms', 'centroid'];
  const rows = results.filter(function (r) { return r.seconds !== undefined; }).map(function (r) {
    const inGame = typeof r.gameVolume === 'number' ? (r.rmsDb + db(r.gameVolume)).toFixed(1) : '';
    return [r.file + (r.loop ? ' (loop)' : ''), r.seconds.toFixed(2), String(r.sampleRate), r.peakDb.toFixed(1), r.rmsDb.toFixed(1), inGame, r.leadMs.toFixed(0), Math.round(r.centroidHz) + ' Hz'];
  });
  const widths = head.map(function (h, i) { return Math.max(h.length, ...rows.map(function (r) { return r[i].length; })); });
  const line = function (cells) { return cells.map(function (c, i) { return i === 0 ? c.padEnd(widths[i]) : c.padStart(widths[i]); }).join('  '); };
  console.log(line(head));
  rows.forEach(function (r) { console.log(line(r)); });
  console.log('\n"in-game" = RMS after the mix.json volume: compare these to check the balance between sounds.');
  let problems = 0;
  results.forEach(function (r) {
    r.errors.forEach(function (m) { console.log('ERROR ' + r.file + ': ' + m); problems++; });
    r.warnings.forEach(function (m) { console.log('warn  ' + r.file + ': ' + m); problems++; });
  });
  if (!problems) console.log('No problems found in ' + results.length + ' files.');
  return failed ? 1 : 0;
}

process.exitCode = main();
