#!/usr/bin/env node
// ABOUTME: Validates rule files for required structure and content.
// ABOUTME: Checks for Always/Never sections and minimum content.

const fs = require('fs');
const path = require('path');

const rulesDir = path.join(__dirname, '..', '..', 'rules');
let errors = 0;
let fileCount = 0;

if (!fs.existsSync(rulesDir)) {
  console.log('WARNING: rules/ directory not found');
  process.exit(0);
}

function walkDir(dir) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      walkDir(fullPath);
    } else if (entry.name.endsWith('.md') && entry.name !== 'README.md') {
      validateRule(fullPath, path.relative(rulesDir, fullPath));
      fileCount++;
    }
  }
}

function validateRule(filePath, relativePath) {
  const content = fs.readFileSync(filePath, 'utf-8');

  // Check for heading
  if (!content.includes('# ')) {
    console.log(`ERROR: ${relativePath} - Missing heading`);
    errors++;
  }

  // Check for Always or Never section (expected in rule files)
  const hasAlways = content.includes('## Always');
  const hasNever = content.includes('## Never');

  if (!hasAlways && !hasNever) {
    console.log(`WARNING: ${relativePath} - Missing '## Always' or '## Never' section`);
  }

  // Check minimum content
  if (content.length < 200) {
    console.log(`WARNING: ${relativePath} - Very short content (${content.length} chars)`);
  }

  // Check for bullet points (rules should have actionable items)
  const bulletCount = (content.match(/^- /gm) || []).length;
  if (bulletCount < 3) {
    console.log(`WARNING: ${relativePath} - Few actionable items (${bulletCount} bullets)`);
  }
}

walkDir(rulesDir);
console.log(`Rules validated: ${fileCount}, Errors: ${errors}`);
process.exit(errors > 0 ? 1 : 0);
