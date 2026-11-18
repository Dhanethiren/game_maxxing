#!/usr/bin/env node
/* Builds the Sound Studio page: the template with synth.js inlined, so the
 * page and the game's renderer share one sound engine.
 *   node tool/sound/build_studio.js <output.html>                       */
'use strict';
const fs = require('fs');
const path = require('path');
const out = process.argv[2] || path.join(__dirname, 'studio.html');
const tpl = fs.readFileSync(path.join(__dirname, 'studio.template.html'), 'utf8');
const synth = fs.readFileSync(path.join(__dirname, 'synth.js'), 'utf8');
if (synth.includes('</script')) throw new Error('synth.js must not contain </script');
fs.writeFileSync(out, tpl.replace('/*SYNTH*/', () => synth));
console.log('Wrote', out, (fs.statSync(out).size / 1024).toFixed(1) + ' KB');
