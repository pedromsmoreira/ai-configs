#!/bin/bash
#
# setup-cursor.sh - Set up Cursor AI configuration using git submodules
#
# Adds this repository as a git submodule and creates symlinks to shared AI configs
# (rules, skills, agents). The project-specific project-context.mdc is copied
# for customization.
#
# Usage:
#   ./setup-cursor.sh [project-path]
#
# Arguments:
#   project-path  Path to target project (default: current directory)
#
# Environment:
#   AI_CONFIGS_REPO  Override submodule repository URL
#                    (default: https://github.com/your-org/ai-configs.git)
#
# Examples:
#   ./setup-cursor.sh
#   ./setup-cursor.sh /path/to/my-project
#   AI_CONFIGS_REPO=https://github.com/your-org/ai-configs.git ./setup-cursor.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# Submodule repository URL
SUBMODULE_REPO="${AI_CONFIGS_REPO:-https://github.com/your-org/ai-configs.git}"

# Target location: argument or current directory
PROJECT_PATH="${1:-.}"
cd "$PROJECT_PATH"

# Validate git repository
if [ ! -d ".git" ]; then
    echo -e "${YELLOW}Initializing git repository...${NC}"
    git init
fi

DEST=".cursor"
SUBMODULE_PATH="$DEST/ai-configs"
SOURCE_CURSOR="$SUBMODULE_PATH/.cursor"

echo -e "${CYAN}Setting up Cursor config with git submodule...${NC}"
echo "  Repository: $SUBMODULE_REPO"
echo "  Target: $PROJECT_PATH"

# Add submodule if it doesn't exist
if [ ! -d "$SUBMODULE_PATH" ]; then
    echo -e "${CYAN}  Adding git submodule...${NC}"
    git submodule add "$SUBMODULE_REPO" "$SUBMODULE_PATH"
    echo -e "${GREEN}  Submodule added${NC}"
else
    echo -e "${GRAY}  Submodule already exists, updating...${NC}"
    git submodule update --init --recursive "$SUBMODULE_PATH"
fi

# Validate submodule exists
if [ ! -d "$SOURCE_CURSOR" ]; then
    echo -e "${RED}Error: Submodule not properly initialized${NC}"
    exit 1
fi

# Create .cursor/rules directory
RULES_DIR="$DEST/rules"
mkdir -p "$RULES_DIR"
echo -e "${GREEN}  Created: .cursor/rules/${NC}"

# Symlink shared rules (all except project-context.mdc)
for rule in "$SOURCE_CURSOR/rules/"*.mdc; do
    if [ -f "$rule" ]; then
        filename=$(basename "$rule")
        if [ "$filename" != "project-context.mdc" ]; then
            ln -sf "$rule" "$RULES_DIR/$filename"
            echo -e "${GRAY}  Linked: rules/$filename${NC}"
        fi
    fi
done

# Symlink skills directory
ln -sfn "$SOURCE_CURSOR/skills" "$DEST/skills"
echo -e "${GRAY}  Linked: skills/${NC}"

# Symlink agents directory
ln -sfn "$SOURCE_CURSOR/agents" "$DEST/agents"
echo -e "${GRAY}  Linked: agents/${NC}"

# Copy project context template (only if it doesn't exist)
if [ ! -f "$RULES_DIR/project-context.mdc" ]; then
    cp "$SOURCE_CURSOR/rules/project-context.mdc" "$RULES_DIR/"
    echo -e "${GREEN}  Copied: rules/project-context.mdc${NC}"
else
    echo -e "${GRAY}  Skipped: rules/project-context.mdc (already exists)${NC}"
fi

echo ""
echo -e "${GREEN}Cursor config set up successfully!${NC}"
echo -e "${YELLOW}Next step: Edit .cursor/rules/project-context.mdc for this project.${NC}"
echo -e "${GRAY}To update the submodule: cd .cursor/ai-configs && git pull && cd ../..${NC}"
