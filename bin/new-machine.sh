#!/usr/bin/env bash

# Script to create a new machine configuration that inherits from defaults
# Usage: ./bin/new-machine.sh <hostname> [username]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Gum styling palette (fallbacks to ANSI above if gum is unavailable)
RED_N=197
KIWI_N=156
PINK_N=212
PRIMARY_N=7
BRIGHT_N=15
FAINT_N=103
DARK_N=238

have_gum() { command -v gum >/dev/null 2>&1; }

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DARWIN_DIR="$(dirname "$SCRIPT_DIR")"

# Function to print colored output (uses gum if available)
print_info() {
    if have_gum; then
        gum style --foreground $PRIMARY_N "ℹ $1"
    else
        printf "${BLUE}ℹ${NC} %s\n" "$1"
    fi
}

print_success() {
    if have_gum; then
        gum style --foreground $KIWI_N "✓ $1"
    else
        printf "${GREEN}✓${NC} %s\n" "$1"
    fi
}

print_warning() {
    if have_gum; then
        gum style --foreground $FAINT_N "⚠ $1"
    else
        printf "${YELLOW}⚠${NC} %s\n" "$1"
    fi
}

print_error() {
    if have_gum; then
        gum style --foreground $RED_N "✗ $1"
    else
        printf "${RED}✗${NC} %s\n" "$1"
    fi
}

print_header() {
    if have_gum; then
        gum style --bold --foreground $PINK_N "$1"
        echo ""
    else
        printf "\n${BOLD}${CYAN}%s${NC}\n\n" "$1"
    fi
}

# Function to show usage
show_usage() {
    printf "${BOLD}Usage:${NC}\n"
    printf "    %s <hostname> [username]\n\n" "$(basename "$0")"

    printf "${BOLD}Description:${NC}\n"
    printf "    Create a new machine configuration that inherits from common defaults.\n"
    printf "    This will create the necessary directory structure and configuration files.\n\n"

    printf "${BOLD}Arguments:${NC}\n"
    printf "    hostname    The hostname/identifier for the machine (e.g., work-laptop)\n"
    printf "    username    The username (default: coopermaruyama)\n\n"

    printf "${BOLD}Examples:${NC}\n"
    printf "    %s work-laptop\n" "$(basename "$0")"
    printf "    %s mac-mini coopermaruyama\n" "$(basename "$0")"
    printf "    %s studio-mac\n\n" "$(basename "$0")"

    printf "${BOLD}What this script does:${NC}\n"
    printf "    1. Creates host configuration in hosts/<hostname>/\n"
    printf "    2. Creates home-manager configuration in home/<username>/<hostname>/\n"
    printf "    3. Adds entry to flake.nix darwinConfigurations\n"
    printf "    4. Adds entry to flake.nix homeConfigurations\n"
    printf "    5. Shows next steps for activation\n\n"

    printf "${BOLD}Note:${NC}\n"
    printf "    The new machine will inherit all settings from common defaults.\n"
    printf "    You can customize individual settings in the generated files.\n"
}

# Check arguments
if [ $# -eq 0 ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    show_usage
    exit 0
fi

HOSTNAME="$1"
USERNAME="${2:-coopermaruyama}"

# Validate hostname format (alphanumeric and hyphens)
if ! [[ "$HOSTNAME" =~ ^[a-zA-Z0-9-]+$ ]]; then
    print_error "Invalid hostname format. Use only alphanumeric characters and hyphens."
    exit 1
fi

# Convert hostname to proper formats
HOSTNAME_LOWER=$(echo "$HOSTNAME" | tr '[:upper:]' '[:lower:]')
# For display name: capitalize first letter of each word, replace hyphens with spaces
HOSTNAME_DISPLAY=$(echo "$HOSTNAME" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1' | sed 's/ /-/g')
HOSTNAME_SYSTEM="$HOSTNAME_DISPLAY"

print_header "Creating new machine configuration: $HOSTNAME_LOWER"
print_info "Username: $USERNAME"
print_info "Display name: $HOSTNAME_DISPLAY"

# Check if configuration already exists
if [ -d "$DARWIN_DIR/hosts/$HOSTNAME_LOWER" ]; then
    print_error "Host configuration already exists at hosts/$HOSTNAME_LOWER"
    exit 1
fi

if [ -d "$DARWIN_DIR/home/$USERNAME/$HOSTNAME_LOWER" ]; then
    print_error "Home configuration already exists at home/$USERNAME/$HOSTNAME_LOWER"
    exit 1
fi

# Create host configuration
print_header "1. Creating host configuration"
mkdir -p "$DARWIN_DIR/hosts/$HOSTNAME_LOWER"
cat > "$DARWIN_DIR/hosts/$HOSTNAME_LOWER/default.nix" << EOF
{ inputs, darwinModules, ... }:

{
  # Import common Darwin settings
  imports = [
    "\${darwinModules}/common"
  ];

  # Machine-specific network settings
  networking.hostName = "$HOSTNAME_SYSTEM";
  networking.computerName = "$HOSTNAME_DISPLAY";
  networking.localHostName = "$HOSTNAME_SYSTEM";

  # System configuration
  system = {
    stateVersion = 1;

    # You can override any defaults here
    # Uncomment and customize as needed:

    # defaults = {
    #   dock = {
    #     autohide = true;
    #   };
    #   finder = {
    #     AppleShowAllExtensions = true;
    #   };
    # };
  };

  # Machine-specific packages
  environment.systemPackages = [
    # Add machine-specific packages here
  ];
}
EOF
print_success "Created hosts/$HOSTNAME_LOWER/default.nix"

# Create home-manager configuration
print_header "2. Creating home-manager configuration"
mkdir -p "$DARWIN_DIR/home/$USERNAME/$HOSTNAME_LOWER"
cat > "$DARWIN_DIR/home/$USERNAME/$HOSTNAME_LOWER/default.nix" << EOF
{ config, pkgs, lib, hmModules, ... }:

{
  # Import common home-manager settings
  imports = [
    "\${hmModules}/common"
  ];

  # Home Manager basic configuration
  home = {
    username = "$USERNAME";
    homeDirectory = lib.mkForce "/Users/$USERNAME";
    stateVersion = "24.05";
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Machine-specific home configuration
  # You can override any common settings here or add new ones

  # Example: Add machine-specific packages
  # home.packages = with pkgs; [
  #   # Add packages here
  # ];

  # Example: Override shell aliases
  # programs.zsh.shellAliases = {
  #   # Add or override aliases here
  # };
}
EOF
print_success "Created home/$USERNAME/$HOSTNAME_LOWER/default.nix"

# Update flake.nix
print_header "3. Updating flake.nix"

# Check if the machine already exists in flake.nix
if grep -q "\"$HOSTNAME_SYSTEM\"" "$DARWIN_DIR/flake.nix"; then
    print_warning "Machine $HOSTNAME_SYSTEM already exists in flake.nix, skipping update"
else
    # Create backup
    cp "$DARWIN_DIR/flake.nix" "$DARWIN_DIR/flake.nix.backup"
    print_info "Created backup at flake.nix.backup"

    # Add darwin configuration
    # Find the darwinConfigurations section and add new entry
    awk -v hostname="$HOSTNAME_SYSTEM" -v hostname_lower="$HOSTNAME_LOWER" -v username="$USERNAME" '
    /darwinConfigurations = {/ {
        print
        getline
        print
        print "      \"" hostname "\" = mkDarwinConfiguration \"" hostname_lower "\" \"" username "\";"
        next
    }
    /homeConfigurations = {/ {
        print
        getline
        print
        print "        \"" username "@" hostname_lower "\" = mkHomeConfiguration \"aarch64-darwin\" \"" username "\" \"" hostname_lower "\";"
        next
    }
    { print }
    ' "$DARWIN_DIR/flake.nix.backup" > "$DARWIN_DIR/flake.nix"

    print_success "Updated flake.nix with new machine configuration"
fi

# Summary
print_header "✅ Configuration created successfully!"

printf "${BOLD}${GREEN}Machine Configuration Summary:${NC}\n"
printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"

printf "${BOLD}Hostname:${NC}      %s\n" "$HOSTNAME_SYSTEM"
printf "${BOLD}Username:${NC}      %s\n" "$USERNAME"
printf "${BOLD}Flake name:${NC}    .#%s\n\n" "$HOSTNAME_SYSTEM"

printf "${BOLD}Files created:${NC}\n"
printf "  • hosts/%s/default.nix\n" "$HOSTNAME_LOWER"
printf "  • home/%s/%s/default.nix\n\n" "$USERNAME" "$HOSTNAME_LOWER"

printf "${BOLD}Flake updated:${NC}\n"
printf "  • Added to darwinConfigurations\n"
printf "  • Added to homeConfigurations\n\n"

printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"

printf "${BOLD}${CYAN}Next Steps:${NC}\n\n"

printf "${BOLD}1. Review the generated configuration files:${NC}\n"
printf "   ${CYAN}\$ cat hosts/%s/default.nix${NC}\n" "$HOSTNAME_LOWER"
printf "   ${CYAN}\$ cat home/%s/%s/default.nix${NC}\n\n" "$USERNAME" "$HOSTNAME_LOWER"

printf "${BOLD}2. Customize as needed (both files have comments to guide you)${NC}\n\n"

printf "${BOLD}3. Test the configuration:${NC}\n"
printf "   ${CYAN}\$ nix flake check${NC}\n\n"

printf "${BOLD}4. On the new machine, clone this repo and build:${NC}\n"
printf "   ${CYAN}\$ git clone <your-repo> ~/darwin${NC}\n"
printf "   ${CYAN}\$ cd ~/darwin${NC}\n"
printf "   ${CYAN}\$ darwin-rebuild switch --flake .#%s${NC}\n\n" "$HOSTNAME_SYSTEM"

printf "${BOLD}5. Or use the helper script:${NC}\n"
printf "   ${CYAN}\$ drbs${NC}\n\n"

printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"

printf "${BOLD}${YELLOW}Note:${NC} The new machine inherits ALL common settings from:\n"
printf "  • modules/darwin/common/\n"
printf "  • modules/home-manager/common/\n\n"
printf "You can override any setting in the generated configuration files.\n\n"

printf "${BOLD}${GREEN}Happy configuring! 🚀${NC}\n"
