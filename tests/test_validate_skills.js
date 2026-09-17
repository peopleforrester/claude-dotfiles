#!/usr/bin/env node
// ABOUTME: Unit tests for scripts/ci/validate-skills.js frontmatter field checks.
// ABOUTME: Confirms the known-field set comes from schemas/skill.schema.json.

const fs = require('fs');
const os = require('os');
const path = require('path');
const { execSync } = require('child_process');

const ROOT = path.join(__dirname, '..');
const VALIDATOR = path.join(ROOT, 'scripts', 'ci', 'validate-skills.js');
const SCHEMA = path.join(ROOT, 'schemas', 'skill.schema.json');

// The validator resolves its paths as __dirname/../.., so a test fixture has to
// reproduce that layout. Same approach as tests/test_validate_agents.js.
function makeTempSkill(frontmatter) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'skill-test-'));
  const skillDir = path.join(dir, 'skills', 'sample');
  fs.mkdirSync(skillDir, { recursive: true });
  fs.writeFileSync(path.join(skillDir, 'SKILL.md'),
    `---\n${frontmatter}\n---\n\n# Sample\n\nA test skill that does sample things. This body is long enough to pass validation without tripping the short-body warning.\n`
  );
  const ciDir = path.join(dir, 'scripts', 'ci');
  fs.mkdirSync(ciDir, { recursive: true });
  fs.copyFileSync(VALIDATOR, path.join(ciDir, 'validate-skills.js'));
  const schemaDir = path.join(dir, 'schemas');
  fs.mkdirSync(schemaDir, { recursive: true });
  fs.copyFileSync(SCHEMA, path.join(schemaDir, 'skill.schema.json'));
  return dir;
}

function runValidator(root) {
  try {
    const out = execSync('node scripts/ci/validate-skills.js', { cwd: root, encoding: 'utf-8' });
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

console.log('tests/test_validate_skills.js');

// Every field the schema declares is accepted without complaint.
{
  const { code, out } = runValidator(makeTempSkill(
    'name: sample\ndescription: A sample skill.\nmodel: opus\neffort: high\nuser-invocable: true'
  ));
  expect('schema-declared fields accepted', code === 0 && !out.includes('Unknown frontmatter field'));
}

// A field the schema does not declare is reported. Without this, a typo such as
// "descripton:" passes silently and the skill never gets a description.
{
  const { out } = runValidator(makeTempSkill(
    'name: sample\ndescription: A sample skill.\ninvented-field: true'
  ));
  expect('unknown field reported', out.includes('invented-field'));
}

// The name length limit is the schema's, not a second copy of the number.
{
  const schema = JSON.parse(fs.readFileSync(SCHEMA, 'utf-8'));
  const max = schema.properties.name.maxLength;
  expect('schema carries a name maxLength', typeof max === 'number');
  const { code, out } = runValidator(makeTempSkill(
    `name: ${'a'.repeat(max + 1)}\ndescription: A sample skill.`
  ));
  expect('over-length name errors', code !== 0 && out.includes('exceeds'));
}

console.log('  all: PASS');
