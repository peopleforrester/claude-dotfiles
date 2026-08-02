#!/usr/bin/env node
// ABOUTME: Validates hook configuration files for correct structure and types.
// ABOUTME: Checks event names, nested handler shape, handler types, and matcher form.

const fs = require('fs');
const path = require('path');

const hooksDir = path.join(__dirname, '..', '..', 'hooks');
const schemaPath = path.join(__dirname, '..', '..', 'schemas', 'hooks.schema.json');
let errors = 0;
let fileCount = 0;

if (!fs.existsSync(hooksDir)) {
  console.log('WARNING: hooks/ directory not found');
  process.exit(0);
}

// Source of truth for valid events and handler types: the schema. Hardcoding a
// subset here was the M1 drift bug — valid events triggered "Unknown hook type".
const schema = JSON.parse(fs.readFileSync(schemaPath, 'utf-8'));
const validEvents = Object.keys(schema.properties.hooks.properties);
const validHandlerTypes = (schema.$defs && schema.$defs.handler &&
  schema.$defs.handler.properties.type.enum) ||
  ['command', 'http', 'mcp_tool', 'prompt', 'agent'];

// A key is an event key if it is an exact event name or an event-prefixed
// variant like "PostToolUse_uv" (example files stack alternatives in one file).
function isEventKey(key) {
  return validEvents.some(ev => key === ev || key.startsWith(ev + '_'));
}

// Matchers are tool names ("Bash", "Edit|Write"), "*"/"" for all, or a regex.
// They are NOT expressions and NOT permission rules. Flag the two mistakes that
// silently never match: an expression (`tool == "Bash"`) and a permission-rule
// form (`Bash(git push *)`) used where a matcher belongs.
function looksLikeBadMatcher(m) {
  if (typeof m !== 'string') return false;
  if (m.includes('==') || m.includes('&&') || m.includes('tool_input') ||
      m.includes(' matches ')) return true;
  if (/^[A-Za-z][\w-]*\([^)]*\)/.test(m)) return true;
  return false;
}

function validateEventArray(fileName, eventKey, arr) {
  if (!Array.isArray(arr)) {
    console.log(`ERROR: ${fileName} - ${eventKey} should be an array`);
    errors++;
    return;
  }
  for (const group of arr) {
    if (group === null || typeof group !== 'object') continue;
    if (looksLikeBadMatcher(group.matcher)) {
      console.log(`WARNING: ${fileName} - ${eventKey} matcher '${group.matcher}' is not a tool-name matcher; use a tool name (Bash, Edit|Write) and scope inputs with a handler 'if'`);
    }
    const handlers = group.hooks;
    if (handlers === undefined) continue;
    if (!Array.isArray(handlers)) {
      console.log(`ERROR: ${fileName} - ${eventKey} group 'hooks' must be an array of handlers`);
      errors++;
      continue;
    }
    for (const h of handlers) {
      if (h === null || typeof h !== 'object') continue;
      if (h.type !== undefined && !validHandlerTypes.includes(h.type)) {
        console.log(`ERROR: ${fileName} - ${eventKey} handler type '${h.type}' is invalid (allowed: ${validHandlerTypes.join(', ')})`);
        errors++;
      }
    }
  }
}

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

  // Strip string-valued "// comment" keys before parsing.
  const cleanedContent = content.replace(/"\/\/[^"]*":\s*"[^"]*",?\n?/g, '');

  let parsed;
  try {
    parsed = JSON.parse(cleanedContent);
  } catch (err) {
    try {
      parsed = JSON.parse(content);
    } catch (err2) {
      console.log(`ERROR: ${fileName} - Invalid JSON: ${err2.message}`);
      errors++;
      return;
    }
  }
  if (parsed === null || typeof parsed !== 'object') return;

  // Events live either under a top-level "hooks" map (settings-style) or at the
  // top level (example files copy one event section into settings.json).
  const underHooksMap = parsed.hooks && typeof parsed.hooks === 'object';
  const root = underHooksMap ? parsed.hooks : parsed;

  for (const [key, val] of Object.entries(root)) {
    if (isEventKey(key)) {
      validateEventArray(fileName, key, val);
    } else if (underHooksMap && !key.startsWith('//')) {
      console.log(`WARNING: ${fileName} - Unknown hook type: ${key}`);
    }
  }
}

walkDir(hooksDir);
console.log(`Hook files validated: ${fileCount}, Errors: ${errors}`);
process.exit(errors > 0 ? 1 : 0);
