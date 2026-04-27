#!/usr/bin/env node
// ABOUTME: Asserts that README inventory counts match filesystem reality.
// ABOUTME: Catches drift between docs and code (senior review H1).

const fs = require('fs');
const path = require('path');

const ROOT = path.join(__dirname, '..');

function countFiles(dir, predicate) {
  if (!fs.existsSync(dir)) return 0;
  let count = 0;
  function walk(d) {
    for (const entry of fs.readdirSync(d, { withFileTypes: true })) {
      const full = path.join(d, entry.name);
      if (entry.isDirectory()) walk(full);
      else if (predicate(entry.name, full)) count++;
    }
  }
  walk(dir);
  return count;
}

const counts = {
  agents: countFiles(path.join(ROOT, 'agents'), n => n.endsWith('.md') && n !== 'README.md'),
  skills: countFiles(path.join(ROOT, 'skills'), n => n === 'SKILL.md'),
  rules: countFiles(path.join(ROOT, 'rules'), n => n.endsWith('.md') && n !== 'README.md'),
  claudeMd: countFiles(path.join(ROOT, 'claude-md'), n => n.endsWith('.md') && n !== 'README.md'),
  hooks: countFiles(path.join(ROOT, 'hooks'),
    (n, p) => n !== 'README.md' && !n.endsWith('.schema.json') && !p.includes('templates/')),
  mcp: countFiles(path.join(ROOT, 'mcp'), n => n.endsWith('.json') && !n.endsWith('.schema.json')),
};

const readme = fs.readFileSync(path.join(ROOT, 'README.md'), 'utf-8');

function expect(label, claim, actual) {
  if (claim !== actual) {
    console.log(`FAIL: ${label}: README claims ${claim}, filesystem has ${actual}`);
    process.exit(1);
  }
  console.log(`  ${label}: PASS (${actual})`);
}

console.log('tests/test_inventory.js');

function readClaim(pattern) {
  const m = readme.match(pattern);
  return m ? parseInt(m[1], 10) : null;
}

expect('agents count',     readClaim(/\| (\d+) agents \|/),    counts.agents);
expect('skills count',     readClaim(/\| (\d+) skills \|/),    counts.skills);
expect('rules count',      readClaim(/\| (\d+) rules \|/),     counts.rules);
expect('claude-md count',  readClaim(/\| (\d+) templates \|/), counts.claudeMd);
expect('hooks count',      readClaim(/\| (\d+) hooks \|/),     counts.hooks);
expect('mcp count',        readClaim(/\| (\d+) configs \|/),   counts.mcp);

console.log('  all: PASS');
