#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🔄 Rebuilding Darwin configuration...${NC}"

# Check if we're in the right directory
if [ ! -f "flake.nix" ]; then
    echo -e "${RED}Error: flake.nix not found. Please run this script from the Darwin configuration directory.${NC}"
    exit 1
fi

# Update flake inputs if requested
if [ "${1:-}" = "--update" ]; then
    echo -e "${YELLOW}📦 Updating flake inputs...${NC}"
    nix flake update
fi

# Build the configuration
echo -e "${YELLOW}🔨 Building configuration...${NC}"
if darwin-rebuild build --flake .#"Coopers-MacBook-Pro"; then
    echo -e "${GREEN}✅ Build successful!${NC}"
else
    echo -e "${RED}❌ Build failed!${NC}"
    exit 1
fi

# Apply the configuration
echo -e "${YELLOW}🚀 Applying configuration...${NC}"
if sudo darwin-rebuild switch --flake .#"Coopers-MacBook-Pro"; then
    echo -e "${GREEN}✅ Configuration applied successfully!${NC}"
    echo -e "${GREEN}🎉 Darwin rebuild complete!${NC}"
else
    echo -e "${RED}❌ Failed to apply configuration!${NC}"
    exit 1
fi
