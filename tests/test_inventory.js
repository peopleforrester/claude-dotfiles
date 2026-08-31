#!/usr/bin/env node
// ABOUTME: Asserts that README inventory counts match what the repository tracks.
// ABOUTME: Counts git-tracked files, not the working tree, so a clone agrees.

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const ROOT = path.join(__dirname, '..');

// Count what git tracks, not what is on disk. Walking the filesystem counted
// files the repository does not have: an unanchored `docs/` ignore rule hid
// skills/docs/update-docs/SKILL.md, so the working tree carried 70 skills and a
// clone carried 69. This test passed locally and CI failed on every run for
// three weeks. A checkout is the thing users get, so it is the thing to measure.
const tracked = execSync('git ls-files -z', { cwd: ROOT, maxBuffer: 32 * 1024 * 1024 })
  .toString('utf-8')
  .split('\0')
  .filter(Boolean);

function countTracked(prefix, predicate) {
  return tracked.filter(p => p.startsWith(prefix + '/'))
                .filter(p => predicate(path.basename(p), p))
                .length;
}

const counts = {
  agents: countTracked('agents', n => n.endsWith('.md') && n !== 'README.md'),
  skills: countTracked('skills', n => n === 'SKILL.md'),
  rules: countTracked('rules', n => n.endsWith('.md') && n !== 'README.md'),
  claudeMd: countTracked('claude-md', n => n.endsWith('.md') && n !== 'README.md'),
  hooks: countTracked('hooks',
    (n, p) => n !== 'README.md' && !n.endsWith('.schema.json') && !p.includes('templates/')),
  mcp: countTracked('mcp', n => n.endsWith('.json') && !n.endsWith('.schema.json')),
  profiles: countTracked('settings/permissions', n => n.endsWith('.json')),
};

const readme = fs.readFileSync(path.join(ROOT, 'README.md'), 'utf-8');

function expect(label, claim, actual) {
  if (claim !== actual) {
    console.log(`FAIL: ${label}: README claims ${claim}, repository tracks ${actual}`);
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
expect('profiles count',   readClaim(/\| (\d+) profiles \|/),  counts.profiles);

console.log('  all: PASS');
