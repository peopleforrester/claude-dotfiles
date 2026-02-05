#!/usr/bin/env node
// ABOUTME: Validates command definition files for required structure.
// ABOUTME: Checks frontmatter fields and content quality.

const fs = require('fs');
const path = require('path');

const commandsDir = path.join(__dirname, '..', '..', 'commands');
let errors = 0;
let fileCount = 0;

if (!fs.existsSync(commandsDir)) {
  console.log('WARNING: commands/ directory not found');
  process.exit(0);
}

function walkDir(dir) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      walkDir(fullPath);
    } else if (entry.name.endsWith('.md') && entry.name !== 'README.md') {
      validateCommand(fullPath, entry.name);
      fileCount++;
    }
  }
}

function validateCommand(filePath, fileName) {
  const content = fs.readFileSync(filePath, 'utf-8');

  // Check frontmatter exists
  if (!content.startsWith('---')) {
    console.log(`ERROR: ${fileName} - Missing YAML frontmatter`);
    errors++;
    return;
  }

  const frontmatterEnd = content.indexOf('---', 3);
  if (frontmatterEnd === -1) {
    console.log(`ERROR: ${fileName} - Unclosed YAML frontmatter`);
    errors++;
    return;
  }

  const frontmatter = content.substring(3, frontmatterEnd);

  // Check required fields
  if (!frontmatter.includes('description:')) {
    console.log(`ERROR: ${fileName} - Missing required field: description`);
    errors++;
  }

  // Check body content
  const body = content.substring(frontmatterEnd + 3).trim();
  if (body.length < 30) {
    console.log(`WARNING: ${fileName} - Very short body (${body.length} chars)`);
  }
}

walkDir(commandsDir);
console.log(`Commands validated: ${fileCount}, Errors: ${errors}`);
process.exit(errors > 0 ? 1 : 0);
