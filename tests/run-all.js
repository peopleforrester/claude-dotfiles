#!/usr/bin/env node
// ABOUTME: Test runner for claude-dotfiles validation.
// ABOUTME: Runs all CI validators and reports aggregate results.

const { execSync } = require('child_process');
const path = require('path');

const rootDir = path.join(__dirname, '..');
let passed = 0;
let failed = 0;

function run(label, command) {
  process.stdout.write(`  ${label}... `);
  try {
    execSync(command, { cwd: rootDir, encoding: 'utf-8', timeout: 30000 });
    console.log('PASS');
    passed++;
  } catch (err) {
    console.log('FAIL');
    if (err.stdout) console.log(err.stdout);
    if (err.stderr) console.log(err.stderr);
    failed++;
  }
}

console.log('claude-dotfiles test suite\n');

// Structural validation
run('Validate agents', 'node scripts/ci/validate-agents.js');
run('Validate skills', 'node scripts/ci/validate-skills.js');
run('Validate rules', 'node scripts/ci/validate-rules.js');
run('Validate hooks', 'node scripts/ci/validate-hooks.js');

// JSON parsing
run('Parse JSON configs', `node -e "
  const fs = require('fs');
  const path = require('path');
  const fixed = [
    'settings/settings.json',
    '.claude-plugin/plugin.json',
    '.claude-plugin/marketplace.json',
    'hooks/hooks.json',
    'schemas/hooks.schema.json',
    'schemas/plugin.schema.json',
    'schemas/skill.schema.json',
  ];
  const profilesDir = path.join('${rootDir.replace(/'/g, "\\'")}', 'settings/permissions');
  const profileFiles = fs.readdirSync(profilesDir)
    .filter(f => f.endsWith('.json'))
    .map(f => path.join('settings/permissions', f));
  const files = [...fixed, ...profileFiles];
  let errors = 0;
  for (const f of files) {
    try {
      JSON.parse(fs.readFileSync(path.join('${rootDir.replace(/'/g, "\\'")}', f), 'utf-8'));
    } catch (e) {
      console.log('  ERROR: ' + f + ' - ' + e.message);
      errors++;
    }
  }
  if (errors > 0) process.exit(1);
"`);

// Plugin manifest checks
run('Plugin manifest integrity', `node -e "
  const plugin = require('./.claude-plugin/plugin.json');
  const assert = (cond, msg) => { if (!cond) { console.log('FAIL: ' + msg); process.exit(1); } };
  assert(plugin.name === 'claude-dotfiles', 'Plugin name mismatch');
  assert(plugin.version, 'Missing version');
  assert(plugin.components, 'Missing components');
  assert(plugin.components.skills, 'Missing skills path');
  assert(plugin.components.agents, 'Missing agents path');
  assert(!plugin.components.commands, 'commands path should not exist (migrated to skills in 0.5.0)');
"`);

// Unit tests for helper scripts
run('Unit: token-count parsing', 'python3 tests/test_token_count.py');
run('Unit: protect-sensitive-files', 'python3 tests/test_protect_sensitive_files.py');
run('Unit: validate-agents model enum', 'node tests/test_validate_agents.js');

// Schema validation
run('Schema structure', `node -e "
  const fs = require('fs');
  const schemas = ['hooks', 'plugin', 'skill'];
  for (const s of schemas) {
    const schema = JSON.parse(fs.readFileSync('schemas/' + s + '.schema.json', 'utf-8'));
    if (!schema['\\$schema']) { console.log('Missing \\$schema in ' + s); process.exit(1); }
    if (!schema.title) { console.log('Missing title in ' + s); process.exit(1); }
  }
"`);

console.log(`\n--- Results ---`);
console.log(`  Passed: ${passed}`);
console.log(`  Failed: ${failed}`);
console.log(`  Result: ${failed === 0 ? 'ALL PASS' : 'FAILURES DETECTED'}`);

process.exit(failed > 0 ? 1 : 0);
