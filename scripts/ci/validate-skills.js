#!/usr/bin/env node
// ABOUTME: Validates SKILL.md files for required YAML frontmatter.
// ABOUTME: Checks name, description, and content quality.

const fs = require('fs');
const path = require('path');

const skillsDir = path.join(__dirname, '..', '..', 'skills');
const schemaPath = path.join(__dirname, '..', '..', 'schemas', 'skill.schema.json');

// Source of truth for the field set and the name limit: the schema this repo
// ships. Keeping a second copy of either here is how the two drift, and a
// README that calls these files schema-checked has to mean it.
const schema = JSON.parse(fs.readFileSync(schemaPath, 'utf-8'));
const knownFields = new Set(Object.keys(schema.properties));
const nameMaxLength = schema.properties.name.maxLength;
const namePattern = new RegExp(schema.properties.name.pattern);
let errors = 0;
let fileCount = 0;

if (!fs.existsSync(skillsDir)) {
  console.log('WARNING: skills/ directory not found');
  process.exit(0);
}

function walkDir(dir) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      walkDir(fullPath);
    } else if (entry.name === 'SKILL.md') {
      validateSkill(fullPath, path.relative(skillsDir, fullPath));
      fileCount++;
    }
  }
}

function validateSkill(filePath, relativePath) {
  const content = fs.readFileSync(filePath, 'utf-8');

  // Check frontmatter exists
  if (!content.startsWith('---')) {
    console.log(`ERROR: ${relativePath} - Missing YAML frontmatter`);
    errors++;
    return;
  }

  const frontmatterEnd = content.indexOf('---', 3);
  if (frontmatterEnd === -1) {
    console.log(`ERROR: ${relativePath} - Unclosed YAML frontmatter`);
    errors++;
    return;
  }

  const frontmatter = content.substring(3, frontmatterEnd);

  // Check required fields
  if (!frontmatter.includes('name:')) {
    console.log(`ERROR: ${relativePath} - Missing required field: name`);
    errors++;
  }
  if (!frontmatter.includes('description:')) {
    console.log(`ERROR: ${relativePath} - Missing required field: description`);
    errors++;
  }

  // Check name format (lowercase with hyphens)
  const nameMatch = frontmatter.match(/name:\s*([^\n]+)/);
  if (nameMatch) {
    const name = nameMatch[1].trim();
    if (!namePattern.test(name)) {
      console.log(`WARNING: ${relativePath} - Name should be lowercase-with-hyphens: ${name}`);
    }
    if (name.length > nameMaxLength) {
      console.log(`ERROR: ${relativePath} - Name exceeds ${nameMaxLength} chars: ${name}`);
      errors++;
    }
  }

  // Check every top-level frontmatter key against the schema. A misspelled
  // field is otherwise silently ignored by the harness and by this validator,
  // so `descripton:` reads as a skill with no description at all.
  for (const line of frontmatter.split('\n')) {
    const keyMatch = line.match(/^([A-Za-z][A-Za-z0-9_-]*):/);
    if (keyMatch && !knownFields.has(keyMatch[1])) {
      console.log(`WARNING: ${relativePath} - Unknown frontmatter field: ${keyMatch[1]}`);
    }
  }

  // Check body content
  const body = content.substring(frontmatterEnd + 3).trim();
  if (body.length < 100) {
    console.log(`WARNING: ${relativePath} - Very short body (${body.length} chars)`);
  }
}

walkDir(skillsDir);
console.log(`Skills validated: ${fileCount}, Errors: ${errors}`);
process.exit(errors > 0 ? 1 : 0);
