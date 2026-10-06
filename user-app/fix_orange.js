// One-off: replace hardcoded orange with theme-aware primaryAccent getter.
// Handles const contexts: any `const <expr>` whose extent contains the color
// gets its `const` stripped (primaryAccent is a runtime getter, not const).
const fs = require('fs');
const path = require('path');

const NEEDLE = 'Color(0xFFF57C21)';
const NEEDLE_RE = /Color\(0xFFF57C21\)/gi;
const REPL = 'primaryAccent';

const DRY = process.argv.includes('--dry');

function walk(dir, out = []) {
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    if (e.isDirectory()) walk(p, out);
    else if (e.name.endsWith('.dart') && !e.name.endsWith('.g.dart') && !e.name.endsWith('.freezed.dart')) out.push(p);
  }
  return out;
}

function matchBalanced(src, start) {
  const open = src[start];
  const close = open === '(' ? ')' : open === '[' ? ']' : open === '{' ? '}' : '>';
  let depth = 0;
  let inStr = null; // quote char
  for (let i = start; i < src.length; i++) {
    const c = src[i];
    if (inStr) {
      if (c === '\\') { i++; continue; }
      if (c === inStr) inStr = null;
      continue;
    }
    if (c === "'" || c === '"' || c === '`') { inStr = c; continue; }
    if (c === open) depth++;
    else if (c === close) { depth--; if (depth === 0) return i + 1; }
  }
  return src.length;
}

const isWordChar = (c) => c && /[A-Za-z0-9_$]/.test(c);

// Remove `const` tokens whose following expression extent contains the needle.
function stripConsts(src, needle) {
  let out = '';
  let i = 0;
  while (true) {
    const idx = src.indexOf('const', i);
    if (idx === -1) { out += src.slice(i); break; }
    const before = src[idx - 1];
    const after = src[idx + 5];
    if (isWordChar(before) || isWordChar(after)) {
      out += src.slice(i, idx + 5);
      i = idx + 5;
      continue;
    }
    // find extent of the expression the const applies to
    let j = idx + 5;
    while (j < src.length && /\s/.test(src[j])) j++;
    let k = j;
    if (k >= src.length) { out += src.slice(i, idx + 5); i = idx + 5; continue; }
    if (src[k] === '(' || src[k] === '[' || src[k] === '{' || src[k] === '<') {
      k = matchBalanced(src, k);
    } else {
      while (k < src.length && /[A-Za-z0-9_$.]/.test(src[k])) k++;
      if (src[k] === '<') k = matchBalanced(src, k);
      while (src[k] === ' ') k++;
      if (src[k] === '(' || src[k] === '[' || src[k] === '{') k = matchBalanced(src, k);
      else if (k === j) { // const with no parseable expression
        out += src.slice(i, idx + 5); i = idx + 5; continue;
      }
    }
    const extent = src.slice(idx, k);
    if (extent.toLowerCase().includes(needle.toLowerCase())) {
      out += src.slice(i, idx);
      // drop the `const` word plus trailing horizontal whitespace (keep newlines)
      let m = idx + 5;
      while (m < src.length && (src[m] === ' ' || src[m] === '\t')) m++;
      i = m;
    } else {
      out += src.slice(i, idx + 5);
      i = idx + 5;
    }
  }
  return out;
}

const files = walk(path.join(__dirname, 'lib'));
let total = 0;
const changed = [];
for (const f of files) {
  const src = fs.readFileSync(f, 'utf8');
  if (!NEEDLE_RE.test(src)) { NEEDLE_RE.lastIndex = 0; continue; }
  NEEDLE_RE.lastIndex = 0;
  let step1 = stripConsts(src, NEEDLE);
  const n = (step1.match(NEEDLE_RE) || []).length;
  NEEDLE_RE.lastIndex = 0;
  let step2 = step1.replace(NEEDLE_RE, REPL);
  // sanity: no `const primaryAccent` should remain
  const bad = /const\s+primaryAccent/.test(step2);
  if (bad) console.log('!! const primaryAccent remains in', f);
  // ensure import for the getter
  if (!/util\/styles\.dart'|util\/core_export\.dart'/.test(step2)) {
    step2 = "import 'package:jdds/util/styles.dart';\n" + step2;
    console.log('added styles import:', f);
  }
  total += n;
  changed.push(`${path.relative(__dirname, f)}: ${n}`);
  if (!DRY) fs.writeFileSync(f, step2);
}
console.log(DRY ? '[DRY RUN]' : '[DONE]');
changed.forEach((c) => console.log(' ', c));
console.log('total replacements:', total, 'files:', changed.length);
