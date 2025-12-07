#!/usr/bin/env bash
set -e

FLAKE_DIR="$HOME/darwin"
SYSTEM_NAME=$(scutil --get ComputerName)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

show_usage() {
  if command -v gum >/dev/null 2>&1; then
    gum style --bold --foreground 212 "🍎 Darwin Configuration Manager"
    echo ""
    gum style --foreground 103 "Usage:"
    gum style --foreground 7   "  darwin <command> [options]"
    echo ""
    gum style --foreground 103 "Commands:"
    gum style --foreground 7   "  apply           - Apply configuration changes (default)"
    gum style --foreground 7   "  build           - Build the configuration without switching"
    gum style --foreground 7   "  check           - Check the configuration for errors"
    gum style --foreground 7   "  commit          - Commit configuration changes with AI-assisted message"
    gum style --foreground 7   "  evolve          - AI-assisted configuration evolution"
    echo ""
    gum style --foreground 103 "Aliases:"
    gum style --foreground 7   "  switch          - Alias for 'apply'"
    gum style --foreground 7   "  up              - Backward-compat alias for 'apply'"
  else
    echo -e "${BLUE}🍎 Darwin Configuration Manager${NC}"
    echo ""
    echo "Usage: darwin <command> [options]"
    echo ""
    echo -e "${CYAN}Commands:${NC}"
    echo "  apply           - Apply configuration changes (default)"
    echo "  build           - Build the configuration without switching"
    echo "  check           - Check the configuration for errors"
    echo "  commit          - Commit changes with AI-assisted message"
    echo "  evolve          - AI-assisted configuration evolution"
    echo ""
    echo -e "${CYAN}Aliases:${NC}"
    echo "  switch          - Alias for 'apply'"
    echo "  up              - Backward-compat alias for 'apply'"
  fi
}

# Check if flake directory exists
if [ ! -d "$FLAKE_DIR" ]; then
  echo -e "${RED}❌ Error: Flake directory not found at $FLAKE_DIR${NC}"
  exit 1
fi

cd "$FLAKE_DIR"

# Determine flake attribute
HOST_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/darwin/host"
if [ -f "$HOST_FILE" ]; then
  HOST_ATTR=$(sed -e 's/[[:space:]]*$//' "$HOST_FILE")
else
  HOST_ATTR=$(scutil --get HostName 2>/dev/null || hostname -s)
  if [ -z "$HOST_ATTR" ]; then
    HOST_ATTR=$(scutil --get LocalHostName 2>/dev/null || hostname)
  fi
fi

COMMAND="${1:-apply}"
shift || true

case "$COMMAND" in
  apply|switch|up)
    echo -e "${BLUE}🔄 Darwin Configuration Manager${NC}"
    echo -e "${YELLOW}Flake directory: $FLAKE_DIR${NC}"

    if git diff-index --quiet HEAD -- 2>/dev/null; then
      echo -e "${GREEN}✓ Git tree is clean${NC}"
    else
      echo -e "${YELLOW}⚠️  Warning: Git tree has uncommitted changes${NC}"
    fi

    echo -e "${YELLOW}🚀 Switching configuration...${NC}"
    sudo darwin-rebuild switch --flake ".#$HOST_ATTR" "$@"
    ;;

  build)
    echo -e "${BLUE}🔄 Darwin Configuration Manager${NC}"
    echo -e "${YELLOW}🔨 Building configuration...${NC}"
    darwin-rebuild build --flake ".#$HOST_ATTR" "$@"
    ;;

  check)
    echo -e "${BLUE}🔄 Darwin Configuration Manager${NC}"
    echo -e "${YELLOW}🔍 Checking configuration...${NC}"
    darwin-rebuild check --flake ".#$HOST_ATTR" "$@"
    ;;

  commit)
    echo -e "${MAGENTA}🤖 AI-Assisted Commit${NC}"
    if git diff-index --quiet HEAD -- 2>/dev/null && [ -z "$(git ls-files --others --exclude-standard)" ]; then
      echo -e "${YELLOW}⚠️  No changes to commit${NC}"
      exit 0
    fi
    claude -p "Analyze the changes in this Darwin/nix-darwin configuration repository and create an appropriate git commit."
    ;;

  evolve)
    echo -e "${MAGENTA}🧬 Darwin Evolution Mode${NC}"
    echo -e "${CYAN}What would you like to change about your system?${NC}"
    echo ""
    read -p "$(echo -e ${CYAN}Your request:${NC} )" USER_REQUEST

    if [ -z "$USER_REQUEST" ]; then
      echo -e "${RED}❌ No request provided${NC}"
      exit 1
    fi

    if command -v codex >/dev/null 2>&1; then
      codex e "I'm working in a nix-darwin configuration repository at $FLAKE_DIR. The user wants to: $USER_REQUEST"
    elif command -v claude >/dev/null 2>&1; then
      claude -p "I'm working in a nix-darwin configuration repository at $FLAKE_DIR. The user wants to: $USER_REQUEST"
    else
      echo -e "${RED}❌ Neither 'codex' nor 'claude' is available.${NC}"
      exit 1
    fi
    ;;

  help|--help|-h)
    show_usage
    ;;

  *)
    echo -e "${RED}❌ Unknown command: $COMMAND${NC}"
    show_usage
    exit 1
    ;;
esac

