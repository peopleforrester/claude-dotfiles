#!/usr/bin/env node
// ABOUTME: Unit tests for scripts/ci/validate-agents.js model enum.
// ABOUTME: Confirms both short names (opus|sonnet|haiku) and full IDs are accepted.

const fs = require('fs');
const os = require('os');
const path = require('path');
const { execSync } = require('child_process');

const ROOT = path.join(__dirname, '..');
const VALIDATOR = path.join(ROOT, 'scripts', 'ci', 'validate-agents.js');

function makeTempAgent(model) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'agent-test-'));
  const agentsDir = path.join(dir, 'agents');
  fs.mkdirSync(agentsDir);
  fs.writeFileSync(path.join(agentsDir, 'sample.md'),
    `---\nname: sample\ndescription: A test agent.\ntools: ["Read"]\nmodel: ${model}\n---\n\n# Sample\n\nA test agent that does sample things. This body is long enough to pass validation.\n`
  );
  // The validator resolves agentsDir as __dirname/../../agents — so we must run
  // it from a matching layout. Symlink the real script into a scripts/ci/ dir
  // of the temp root.
  const ciDir = path.join(dir, 'scripts', 'ci');
  fs.mkdirSync(ciDir, { recursive: true });
  fs.copyFileSync(VALIDATOR, path.join(ciDir, 'validate-agents.js'));
  return dir;
}

function runValidator(root) {
  try {
    const out = execSync(`node scripts/ci/validate-agents.js`, {
      cwd: root, encoding: 'utf-8'
    });
    return { code: 0, out };
  } catch (e) {
    return { code: e.status || 1, out: e.stdout + e.stderr };
  }
}

function expect(label, cond) {
  if (!cond) {
    console.log(`FAIL: ${label}`);
    process.exit(1);
  }
  console.log(`  ${label}: PASS`);
}

console.log('tests/test_validate_agents.js');

// Short names still accepted
for (const m of ['opus', 'sonnet', 'haiku']) {
  const root = makeTempAgent(m);
  const { code, out } = runValidator(root);
  expect(`short name '${m}' accepted without warning`,
    code === 0 && !out.includes('Unknown model'));
}

// Full model IDs accepted
const fullIds = [
  'claude-opus-4-7',
  'claude-sonnet-4-6',
  'claude-sonnet-4-7',
  'claude-haiku-4-5-20251001',
];
for (const id of fullIds) {
  const root = makeTempAgent(id);
  const { code, out } = runValidator(root);
  expect(`full id '${id}' accepted without warning`,
    code === 0 && !out.includes('Unknown model'));
}

// Garbage rejected
const root = makeTempAgent('gpt-4');
const { code, out } = runValidator(root);
expect("'gpt-4' produces warning",
  out.includes('Unknown model'));

console.log('  all: PASS');
