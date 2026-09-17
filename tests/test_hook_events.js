// ABOUTME: Asserts hooks.schema.json carries every hook event and handler field
// ABOUTME: Claude Code documents, since validate-hooks.js derives its rules from it.

const fs = require('fs');
const path = require('path');

const ROOT = path.join(__dirname, '..');
const schema = JSON.parse(
  fs.readFileSync(path.join(ROOT, 'schemas', 'hooks.schema.json'), 'utf-8')
);

// Verified 2026-09-17 against https://code.claude.com/docs/en/hooks.
// validate-hooks.js reads the event list straight off this schema, so an event
// missing here is reported to users as "Unknown hook type" for a config that
// Claude Code accepts. That drift is what this test exists to catch.
const DOCUMENTED_EVENTS = [
  'SessionStart', 'Setup', 'UserPromptSubmit', 'UserPromptExpansion',
  'PreToolUse', 'PermissionRequest', 'PermissionDenied', 'PostToolUse',
  'PostToolUseFailure', 'PostToolBatch', 'Notification', 'MessageDisplay',
  'SubagentStart', 'SubagentStop', 'TaskCreated', 'TaskCompleted',
  'Stop', 'StopFailure', 'TeammateIdle', 'InstructionsLoaded',
  'ConfigChange', 'CwdChanged', 'DirectoryAdded', 'FileChanged',
  'WorktreeCreate', 'WorktreeRemove', 'PreCompact', 'PostCompact',
  'PreModelSwitch', 'PostModelSwitch', 'Elicitation', 'ElicitationResult',
  'SessionEnd',
];

// Handler fields, by the type that uses them. Same source, same date.
const DOCUMENTED_HANDLER_FIELDS = [
  'type', 'if', 'timeout', 'statusMessage', 'once',        // common
  'command', 'args', 'async', 'asyncRewake', 'shell',      // command
  'url', 'headers', 'allowedEnvVars',                      // http
  'server', 'tool', 'input',                               // mcp_tool
  'prompt', 'model',                                       // prompt / agent
];

let failures = 0;
function expect(label, ok, detail) {
  if (ok) {
    console.log(`  ${label}: PASS`);
  } else {
    console.log(`  ${label}: FAIL — ${detail}`);
    failures++;
  }
}

const schemaEvents = Object.keys(schema.properties.hooks.properties);
const missingEvents = DOCUMENTED_EVENTS.filter(e => !schemaEvents.includes(e));
expect('every documented hook event is in the schema', missingEvents.length === 0,
  `missing: ${missingEvents.join(', ')}`);

const undocumented = schemaEvents.filter(e => !DOCUMENTED_EVENTS.includes(e));
expect('schema invents no events', undocumented.length === 0,
  `not in the docs: ${undocumented.join(', ')}`);

const handlerProps = Object.keys(schema.$defs.handler.properties);
const missingFields = DOCUMENTED_HANDLER_FIELDS.filter(f => !handlerProps.includes(f));
expect('every documented handler field is in the schema', missingFields.length === 0,
  `missing: ${missingFields.join(', ')}`);

console.log(failures === 0 ? '\nHook event schema: ALL PASS' : `\nHook event schema: ${failures} FAILED`);
process.exit(failures > 0 ? 1 : 0);
