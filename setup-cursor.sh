#!/bin/bash
#
# setup-cursor.sh - Set up Cursor AI configuration symlinks for a project
#
# Creates symlinks to shared AI configs (rules, skills, agents) from a central
# ai-configs repository. The project-specific 00-project-context.mdc is copied
# for customization.
#
# Usage:
#   ./setup-cursor.sh [project-path]
#
# Arguments:
#   project-path  Path to target project (default: current directory)
#
# Environment:
#   AI_CONFIGS_PATH  Override default source location (default: ~/ai-configs)
#
# Examples:
#   ./setup-cursor.sh
#   ./setup-cursor.sh /path/to/my-project
#   AI_CONFIGS_PATH=/opt/ai-configs ./setup-cursor.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# Source location: environment variable or default
SOURCE="${AI_CONFIGS_PATH:-$HOME/ai-configs}"
SOURCE_CURSOR="$SOURCE/.cursor"

# Target location: argument or current directory
PROJECT_PATH="${1:-.}"
DEST="$PROJECT_PATH/.cursor"

# Validate source exists
if [ ! -d "$SOURCE_CURSOR" ]; then
    echo -e "${RED}Error: ai-configs not found at $SOURCE${NC}"
    echo "Set AI_CONFIGS_PATH or clone to ~/ai-configs"
    exit 1
fi

echo -e "${CYAN}Setting up Cursor config...${NC}"
echo "  Source: $SOURCE"
echo "  Target: $PROJECT_PATH"

# Create .cursor/rules directory
RULES_DIR="$DEST/rules"
mkdir -p "$RULES_DIR"
echo -e "${GREEN}  Created: .cursor/rules/${NC}"

# Symlink shared rules (01-11*.mdc, excluding 00-*)
for rule in "$SOURCE_CURSOR/rules/"0[1-9]*.mdc "$SOURCE_CURSOR/rules/"1*.mdc; do
    if [ -f "$rule" ]; then
        filename=$(basename "$rule")
        ln -sf "$rule" "$RULES_DIR/$filename"
        echo -e "${GRAY}  Linked: rules/$filename${NC}"
    fi
done

# Symlink skills directory
ln -sfn "$SOURCE_CURSOR/skills" "$DEST/skills"
echo -e "${GRAY}  Linked: skills/${NC}"

# Symlink agents directory
ln -sfn "$SOURCE_CURSOR/agents" "$DEST/agents"
echo -e "${GRAY}  Linked: agents/${NC}"

# Copy project context template
cp "$SOURCE_CURSOR/rules/00-project-context.mdc" "$RULES_DIR/"
echo -e "${GREEN}  Copied: rules/00-project-context.mdc${NC}"

echo ""
echo -e "${GREEN}Cursor config linked successfully!${NC}"
echo -e "${YELLOW}Next step: Edit .cursor/rules/00-project-context.mdc for this project.${NC}"
