#!/usr/bin/env node
// ABOUTME: Validates SKILL.md files for required YAML frontmatter.
// ABOUTME: Checks name, description, and content quality.

const fs = require('fs');
const path = require('path');

const skillsDir = path.join(__dirname, '..', '..', 'skills');
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
    if (!/^[a-z0-9-]+$/.test(name)) {
      console.log(`WARNING: ${relativePath} - Name should be lowercase-with-hyphens: ${name}`);
    }
    if (name.length > 64) {
      console.log(`ERROR: ${relativePath} - Name exceeds 64 chars: ${name}`);
      errors++;
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
