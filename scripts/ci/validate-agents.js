#!/usr/bin/env node
// ABOUTME: Validates agent definition files for required structure.
// ABOUTME: Checks frontmatter fields: name, description, tools, model.

const fs = require('fs');
const path = require('path');

const agentsDir = path.join(__dirname, '..', '..', 'agents');
let errors = 0;

if (!fs.existsSync(agentsDir)) {
  console.log('WARNING: agents/ directory not found');
  process.exit(0);
}

const files = fs.readdirSync(agentsDir).filter(f => f.endsWith('.md') && f !== 'README.md');

for (const file of files) {
  const content = fs.readFileSync(path.join(agentsDir, file), 'utf-8');

  // Check frontmatter exists
  if (!content.startsWith('---')) {
    console.log(`ERROR: ${file} - Missing YAML frontmatter`);
    errors++;
    continue;
  }

  const frontmatterEnd = content.indexOf('---', 3);
  if (frontmatterEnd === -1) {
    console.log(`ERROR: ${file} - Unclosed YAML frontmatter`);
    errors++;
    continue;
  }

  const frontmatter = content.substring(3, frontmatterEnd);

  // Check required fields
  const requiredFields = ['name:', 'description:', 'tools:', 'model:'];
  for (const field of requiredFields) {
    if (!frontmatter.includes(field)) {
      console.log(`ERROR: ${file} - Missing required field: ${field.replace(':', '')}`);
      errors++;
    }
  }

  // Check model value
  const modelMatch = frontmatter.match(/model:\s*(\w+)/);
  if (modelMatch) {
    const validModels = ['opus', 'sonnet', 'haiku'];
    if (!validModels.includes(modelMatch[1])) {
      console.log(`WARNING: ${file} - Unknown model: ${modelMatch[1]} (expected: ${validModels.join(', ')})`);
    }
  }

  // Check file has content after frontmatter
  const body = content.substring(frontmatterEnd + 3).trim();
  if (body.length < 50) {
    console.log(`WARNING: ${file} - Very short body (${body.length} chars)`);
  }
}

console.log(`Agents validated: ${files.length}, Errors: ${errors}`);
process.exit(errors > 0 ? 1 : 0);
