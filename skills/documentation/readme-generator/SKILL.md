---
name: readme-generator
description: |
  Generate comprehensive README.md files for projects. Use when the user asks
  to create a README, document a project, or improve existing documentation.
  Creates well-structured READMEs following best practices.
license: MIT
compatibility: Claude Code 2.1+
metadata:
  author: michaelrishiforrester
  version: "1.0.0"
  tags:
    - documentation
    - readme
    - writing
---

# README Generator

Create comprehensive, well-structured README files.

## When to Use

- User asks to create a README
- Project lacks documentation
- Existing README needs improvement
- Open source project preparation

## README Structure

A good README answers these questions in order:

1. **What** is this project?
2. **Why** would someone use it?
3. **How** do they get started?
4. **What** can they do with it?
5. **How** do they contribute?

## Template

```markdown
# Project Name

Brief description (1-2 sentences) of what this project does.

[![License](badge)](link)
[![Build Status](badge)](link)
[![npm version](badge)](link)

## Features

- Key feature 1
- Key feature 2
- Key feature 3

## Quick Start

\`\`\`bash
# Install
npm install project-name

# Run
npx project-name
\`\`\`

## Installation

### Prerequisites

- Node.js 18+
- npm or yarn

### Install

\`\`\`bash
npm install project-name
\`\`\`

## Usage

### Basic Example

\`\`\`typescript
import { something } from 'project-name';

const result = something('input');
console.log(result);
\`\`\`

### Advanced Usage

\`\`\`typescript
import { something, configure } from 'project-name';

configure({
  option: 'value',
});

const result = something('input', { advanced: true });
\`\`\`

## API Reference

### `functionName(param1, param2)`

Description of what the function does.

**Parameters:**
- `param1` (string): Description
- `param2` (object, optional): Description

**Returns:** Description of return value

**Example:**
\`\`\`typescript
const result = functionName('hello', { option: true });
\`\`\`

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `option1` | string | `'default'` | Description |
| `option2` | boolean | `false` | Description |

## Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md).

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing`)
5. Open a Pull Request

## License

[MIT](LICENSE) © [Author Name](https://github.com/username)
```

## Section Guidelines

### Title & Description

```markdown
# TaskFlow

A modern task management API with real-time sync and team collaboration.
```

- Name should be clear and memorable
- Description explains the "what" in one sentence
- Skip marketing fluff

### Badges

Common badges to include:

```markdown
![npm](https://img.shields.io/npm/v/package-name)
![License](https://img.shields.io/badge/license-MIT-blue)
![Build](https://img.shields.io/github/actions/workflow/status/user/repo/ci.yml)
![Coverage](https://img.shields.io/codecov/c/github/user/repo)
```

### Quick Start

```markdown
## Quick Start

\`\`\`bash
npx create-my-app my-project
cd my-project
npm run dev
\`\`\`

Open http://localhost:3000
```

- Should be copy-paste runnable
- Maximum 3-5 commands
- Show the immediate result

### Usage Examples

```markdown
## Usage

### Basic Usage

\`\`\`typescript
import { Client } from 'my-sdk';

const client = new Client({ apiKey: 'xxx' });
const result = await client.getData();
\`\`\`

### With Error Handling

\`\`\`typescript
try {
  const result = await client.getData();
} catch (error) {
  if (error.code === 'RATE_LIMITED') {
    // Handle rate limiting
  }
}
\`\`\`
```

- Start with simplest case
- Progress to more complex examples
- Show real, runnable code

### API Reference

For libraries, document the public API:

```markdown
### `createClient(options)`

Creates a new API client instance.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `apiKey` | string | Yes | Your API key |
| `baseUrl` | string | No | Custom API endpoint |
| `timeout` | number | No | Request timeout in ms |

**Returns:** `Client` instance

**Throws:** `ConfigError` if apiKey is missing
```

## README Types

### Library/Package

Focus on:
- Installation
- API documentation
- Usage examples
- TypeScript types

### CLI Tool

Focus on:
- Installation methods (npm, brew, binary)
- Command reference
- Configuration options
- Common workflows

### Application

Focus on:
- Getting started / deployment
- Environment setup
- Architecture overview
- Screenshots/demos

### API Service

Focus on:
- Authentication
- Endpoint overview
- Request/response examples
- Rate limits

## Quality Checklist

- [ ] Title clearly states what the project is
- [ ] Description explains the value proposition
- [ ] Quick start is copy-paste runnable
- [ ] Examples use realistic, working code
- [ ] All code blocks have language tags
- [ ] Links are valid and not broken
- [ ] No spelling or grammar errors
- [ ] Badges are up-to-date
- [ ] License is specified
- [ ] Contact/contribution info included
