#!/usr/bin/env node
// ABOUTME: Master validation runner for all component types.
// ABOUTME: Executes all validate-*.js scripts and reports aggregate results.

const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs');

const scriptsDir = __dirname;
const validators = fs.readdirSync(scriptsDir)
  .filter(f => f.startsWith('validate-') && f !== 'validate-all.js')
  .sort();

let totalErrors = 0;
let totalWarnings = 0;
const results = [];

console.log('claude-dotfiles: Running all validators\n');

for (const script of validators) {
  const name = script.replace('validate-', '').replace('.js', '');
  process.stdout.write(`  Validating ${name}...`);

  try {
    const output = execSync(`node ${path.join(scriptsDir, script)}`, {
      encoding: 'utf-8',
      timeout: 30000,
    });

    const errors = (output.match(/ERROR/g) || []).length;
    const warnings = (output.match(/WARNING/g) || []).length;
    totalErrors += errors;
    totalWarnings += warnings;

    if (errors > 0) {
      console.log(` FAIL (${errors} errors)`);
      console.log(output);
    } else {
      console.log(` OK${warnings > 0 ? ` (${warnings} warnings)` : ''}`);
    }

    results.push({ name, errors, warnings, status: errors > 0 ? 'FAIL' : 'PASS' });
  } catch (err) {
    totalErrors++;
    console.log(' FAIL (script error)');
    console.log(err.stdout || err.message);
    results.push({ name, errors: 1, warnings: 0, status: 'FAIL' });
  }
}

console.log('\n--- Summary ---');
console.log(`  Validators run: ${results.length}`);
console.log(`  Total errors: ${totalErrors}`);
console.log(`  Total warnings: ${totalWarnings}`);
console.log(`  Result: ${totalErrors === 0 ? 'PASS' : 'FAIL'}`);

process.exit(totalErrors > 0 ? 1 : 0);
