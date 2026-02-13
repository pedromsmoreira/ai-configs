#!/bin/bash
#
# setup-ai.sh - Set up AI editor-agnostic configuration
#
# Minimal setup for any AI editor (Zed, Windsurf, Copilot, etc.): adds ai-configs
# as submodule and deploys AGENTS.md. Does NOT set up Cursor-specific rules,
# skills, or agents. For full Cursor experience, use setup-cursor.sh instead.
#
# Usage:
#   ./setup-ai.sh [project-path]
#
# Arguments:
#   project-path  Path to target project (default: current directory)
#
# Environment:
#   AI_CONFIGS_REPO  Override submodule repository URL
#   CREATE_RULES_LINK  Set to "1" to create .rules symlink to AGENTS.md (Zed)
#
# Examples:
#   ./setup-ai.sh
#   ./setup-ai.sh /path/to/my-project
#   CREATE_RULES_LINK=1 ./setup-ai.sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

SUBMODULE_REPO="${AI_CONFIGS_REPO:-https://github.com/your-org/ai-configs.git}"
PROJECT_PATH="${1:-.}"
cd "$PROJECT_PATH"

if [ ! -d ".git" ]; then
    echo -e "${YELLOW}Initializing git repository...${NC}"
    git init
fi

SUBMODULE_PATH=".cursor/ai-configs"

echo -e "${CYAN}Setting up AI editor-agnostic config...${NC}"
echo "  Repository: $SUBMODULE_REPO"
echo "  Target: $PROJECT_PATH"

if [ ! -d "$SUBMODULE_PATH" ]; then
    echo -e "${CYAN}  Adding git submodule...${NC}"
    mkdir -p "$(dirname "$SUBMODULE_PATH")"
    git submodule add "$SUBMODULE_REPO" "$SUBMODULE_PATH"
    echo -e "${GREEN}  Submodule added${NC}"
else
    echo -e "${GRAY}  Submodule already exists, updating...${NC}"
    git submodule update --init --recursive "$SUBMODULE_PATH"
fi

AGENTS_SOURCE="$SUBMODULE_PATH/AGENTS.md"
if [ ! -f "$AGENTS_SOURCE" ]; then
    echo -e "${RED}Error: AGENTS.md not found in submodule${NC}"
    exit 1
fi

if [ ! -f "AGENTS.md" ]; then
    cp "$AGENTS_SOURCE" "AGENTS.md"
    echo -e "${GREEN}  Copied: AGENTS.md${NC}"
else
    echo -e "${GRAY}  Skipped: AGENTS.md (already exists)${NC}"
fi

if [ "${CREATE_RULES_LINK:-0}" = "1" ]; then
    if [ ! -e ".rules" ]; then
        ln -sf "AGENTS.md" ".rules"
        echo -e "${GREEN}  Linked: .rules -> AGENTS.md (for Zed)${NC}"
    else
        echo -e "${GRAY}  Skipped: .rules (already exists)${NC}"
    fi
fi

echo ""
echo -e "${GREEN}AI config set up successfully!${NC}"
echo -e "${YELLOW}Edit AGENTS.md to customize for your project.${NC}"
echo -e "${GRAY}For full Cursor experience (rules, skills, agents): run setup-cursor.sh${NC}"
