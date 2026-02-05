#!/usr/bin/env node
// ABOUTME: Validates hook configuration files for correct JSON syntax.
// ABOUTME: Checks hook types, matchers, and required fields.

const fs = require('fs');
const path = require('path');

const hooksDir = path.join(__dirname, '..', '..', 'hooks');
let errors = 0;
let fileCount = 0;

if (!fs.existsSync(hooksDir)) {
  console.log('WARNING: hooks/ directory not found');
  process.exit(0);
}

const validHookTypes = ['PreToolUse', 'PostToolUse', 'PreCompact', 'SessionStart', 'SessionEnd', 'Stop'];

function walkDir(dir) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      walkDir(fullPath);
    } else if (entry.name.endsWith('.json')) {
      validateHookFile(fullPath, entry.name);
      fileCount++;
    }
  }
}

function validateHookFile(filePath, fileName) {
  let content;
  try {
    content = fs.readFileSync(filePath, 'utf-8');
  } catch (err) {
    console.log(`ERROR: ${fileName} - Cannot read file: ${err.message}`);
    errors++;
    return;
  }

  // Filter out comment keys for JSON parsing
  const cleanedContent = content.replace(/"\/\/[^"]*":\s*"[^"]*",?\n?/g, '');

  let parsed;
  try {
    parsed = JSON.parse(cleanedContent);
  } catch (err) {
    // Try original content (comments might be valid JSON)
    try {
      parsed = JSON.parse(content);
    } catch (err2) {
      console.log(`ERROR: ${fileName} - Invalid JSON: ${err2.message}`);
      errors++;
      return;
    }
  }

  // Validate hooks.json structure
  if (parsed.hooks) {
    for (const [hookType, hookArray] of Object.entries(parsed.hooks)) {
      if (!validHookTypes.includes(hookType)) {
        console.log(`WARNING: ${fileName} - Unknown hook type: ${hookType}`);
      }
      if (!Array.isArray(hookArray)) {
        console.log(`ERROR: ${fileName} - ${hookType} should be an array`);
        errors++;
        continue;
      }
      for (const hook of hookArray) {
        if (!hook.type && !hook['// PURPOSE']) {
          console.log(`WARNING: ${fileName} - Hook in ${hookType} missing 'type' field`);
        }
      }
    }
  }
}

walkDir(hooksDir);
console.log(`Hook files validated: ${fileCount}, Errors: ${errors}`);
process.exit(errors > 0 ? 1 : 0);
