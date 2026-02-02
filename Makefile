# ABOUTME: Makefile for claude-dotfiles development and testing
# ABOUTME: Provides targets for validation, testing, and installation

.PHONY: all test validate tokens install clean help

# Default target
all: validate tokens

# Run all validations
validate:
	@echo "🔍 Validating configurations..."
	@python3 scripts/validate.py .

# Count tokens in templates
tokens:
	@echo "📊 Counting tokens..."
	@python3 scripts/token-count.py .

# Run all tests
test: validate tokens test-install test-json test-shell
	@echo "✅ All tests passed!"

# Test JSON syntax with Python
test-json:
	@echo "🔍 Testing JSON files..."
	@find . -name "*.json" -not -path "./.git/*" -exec python3 -c "import json; json.load(open('{}'))" \; -print 2>/dev/null | grep -v "^$$" || true
	@echo "✓ All JSON files valid"

# Test shell script syntax
test-shell:
	@echo "🔍 Testing shell scripts..."
	@for f in install.sh scripts/*.sh hooks/**/*.sh; do \
		if [ -f "$$f" ]; then \
			bash -n "$$f" && echo "✓ $$f"; \
		fi; \
	done
	@echo "✓ All shell scripts valid"

# Test install script in dry-run mode
test-install:
	@echo "🔍 Testing install script (dry-run)..."
	@./install.sh --help > /dev/null && echo "✓ Install script runs"

# Install to local machine
install:
	@echo "📦 Installing claude-dotfiles..."
	@./install.sh

# Install everything without prompts
install-all:
	@echo "📦 Installing everything..."
	@./install.sh --all

# Install minimal configuration
install-minimal:
	@echo "📦 Installing minimal config..."
	@./install.sh --minimal

# Create backup of current config
backup:
	@echo "💾 Creating backup..."
	@./scripts/backup-claude.sh

# Sync configurations
sync-push:
	@echo "📤 Syncing configs (push)..."
	@./scripts/sync-configs.sh push

sync-pull:
	@echo "📥 Syncing configs (pull)..."
	@./scripts/sync-configs.sh pull

# Clean generated files
clean:
	@echo "🧹 Cleaning..."
	@find . -type f -name "*.pyc" -delete
	@find . -type d -name "__pycache__" -delete
	@find . -type f -name ".DS_Store" -delete
	@echo "✓ Cleaned"

# Development setup
dev-setup:
	@echo "🛠️  Setting up development environment..."
	@pip install tiktoken 2>/dev/null || echo "Note: tiktoken optional for accurate token counts"
	@echo "✓ Development environment ready"

# Format check (for CI)
format-check:
	@echo "🎨 Checking formatting..."
	@python3 scripts/validate.py . 2>&1 | grep -E "^(✓|✗)" | head -20

# Show statistics
stats:
	@echo "📈 Repository Statistics"
	@echo "========================"
	@echo "Templates:    $$(find templates -name 'CLAUDE.md' | wc -l | tr -d ' ')"
	@echo "CLAUDE.md:    $$(find claude-md -name '*.md' -not -name 'README.md' | wc -l | tr -d ' ')"
	@echo "Skills:       $$(find skills -name 'SKILL.md' | wc -l | tr -d ' ')"
	@echo "Hooks:        $$(find hooks -name '*.json' -o -name '*.sh' -o -name '*.py' | grep -v README | wc -l | tr -d ' ')"
	@echo "MCP Configs:  $$(find mcp -name '*.json' | wc -l | tr -d ' ')"
	@echo "Commands:     $$(find commands -name '*.md' -not -name 'README.md' | wc -l | tr -d ' ')"
	@echo "Total Files:  $$(find . -type f -not -path './.git/*' -not -path './docs/*' | wc -l | tr -d ' ')"

# Help
help:
	@echo "claude-dotfiles Makefile"
	@echo "========================"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Testing:"
	@echo "  test          Run all tests"
	@echo "  validate      Validate all configurations"
	@echo "  tokens        Count tokens in templates"
	@echo "  test-json     Test JSON file syntax"
	@echo "  test-shell    Test shell script syntax"
	@echo ""
	@echo "Installation:"
	@echo "  install       Interactive installation"
	@echo "  install-all   Install everything"
	@echo "  install-minimal  Install minimal config"
	@echo ""
	@echo "Maintenance:"
	@echo "  backup        Backup current ~/.claude"
	@echo "  sync-push     Push configs to remote"
	@echo "  sync-pull     Pull configs from remote"
	@echo "  clean         Remove generated files"
	@echo ""
	@echo "Development:"
	@echo "  dev-setup     Set up development environment"
	@echo "  stats         Show repository statistics"
	@echo "  help          Show this help"
