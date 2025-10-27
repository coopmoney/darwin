#!/usr/bin/env bash
#
# Bootstrap script for setting up a new Mac with nix-darwin
# This script is idempotent and can be run multiple times safely
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log() {
  printf "${GREEN}🛠  %s${NC}\n" "$*"
}

warn() {
  printf "${YELLOW}⚠️  %s${NC}\n" "$*"
}

error() {
  printf "${RED}❌ %s${NC}\n" "$*" >&2
}

success() {
  printf "${GREEN}✅ %s${NC}\n" "$*"
}

info() {
  printf "${BLUE}ℹ️  %s${NC}\n" "$*"
}

# Get the directory where this script lives
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"

log "Starting bootstrap process..."
info "Script directory: $SCRIPT_DIR"
info "Dotfiles directory: $DOTFILES_DIR"

# Step 1: Check for Command Line Tools
log "Checking for Xcode Command Line Tools..."
if ! xcode-select -p &>/dev/null; then
  warn "Xcode Command Line Tools not found. Installing..."
  xcode-select --install
  warn "Please complete the installation and re-run this script."
  exit 1
else
  success "Xcode Command Line Tools found"
fi

# Step 2: Install Determinate Systems Nix if not present
if ! command -v nix &>/dev/null; then
  log "Installing Determinate Systems Nix..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
    sh -s -- install --no-confirm

  # Source the nix daemon script to make nix available in current shell
  if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
  fi

  success "Nix installed successfully"
else
  success "Nix is already installed"
fi

# Step 3: Ensure experimental features are enabled
log "Checking Nix configuration..."
if [ ! -f /etc/nix/nix.conf ]; then
  warn "Creating /etc/nix/nix.conf..."
  sudo mkdir -p /etc/nix
  echo "experimental-features = nix-command flakes" | sudo tee /etc/nix/nix.conf
elif ! grep -q "experimental-features" /etc/nix/nix.conf 2>/dev/null; then
  warn "Adding experimental features to /etc/nix/nix.conf..."
  echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf
fi
success "Nix configuration is correct"

# Step 4: Get hostname for configuration selection
HOSTNAME=$(hostname -s)
log "Detected hostname: $HOSTNAME"

# Check if there's a configuration for this hostname
if ! grep -q "\"$HOSTNAME\"" "$SCRIPT_DIR/flake.nix"; then
  warn "No configuration found for hostname: $HOSTNAME"
  warn "Available configurations:"
  grep "darwinConfigurations\." "$SCRIPT_DIR/flake.nix" | grep -o '"[^"]*"'

  read -p "Enter the configuration name to use (or press Enter to use default): " CONFIG_NAME
  if [ -z "$CONFIG_NAME" ]; then
    # Use the first available configuration
    CONFIG_NAME=$(grep "darwinConfigurations\." "$SCRIPT_DIR/flake.nix" | head -1 | grep -o '"[^"]*"' | tr -d '"')
  fi
else
  CONFIG_NAME="$HOSTNAME"
fi

info "Using configuration: $CONFIG_NAME"

# Step 5: Install nix-darwin if not present
if ! command -v darwin-rebuild &>/dev/null; then
  log "Installing nix-darwin..."

  # First, we need to build and activate nix-darwin
  nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake "$SCRIPT_DIR#$CONFIG_NAME"

  success "nix-darwin installed successfully"
else
  success "nix-darwin is already installed"
fi

# Step 6: Sync darwin configuration to /etc/nix-darwin if it doesn't match
if [ ! -d /etc/nix-darwin ] || [ "$(readlink -f /etc/nix-darwin)" != "$SCRIPT_DIR" ]; then
  log "Setting up /etc/nix-darwin link..."

  if [ -d /etc/nix-darwin ]; then
    warn "Backing up existing /etc/nix-darwin to /etc/nix-darwin.backup"
    sudo mv /etc/nix-darwin /etc/nix-darwin.backup
  fi

  sudo ln -sf "$SCRIPT_DIR" /etc/nix-darwin
  success "/etc/nix-darwin linked to $SCRIPT_DIR"
else
  success "/etc/nix-darwin already points to the correct location"
fi

# Step 7: Apply the nix-darwin configuration
log "Applying nix-darwin configuration..."
sudo darwin-rebuild switch --flake "$SCRIPT_DIR#$CONFIG_NAME"
success "Configuration applied successfully"

# Step 8: Create local.nix if it doesn't exist
if [ ! -f "$SCRIPT_DIR/local.nix" ]; then
  log "Creating local.nix from template..."
  cp "$SCRIPT_DIR/local.nix.example" "$SCRIPT_DIR/local.nix"
  info "Edit $SCRIPT_DIR/local.nix to customize for this machine"
else
  info "local.nix already exists"
fi

# Step 9: Symlink dotfiles that aren't managed by nix
log "Setting up dotfile symlinks..."

# Array of files to symlink from dotfiles to home directory
declare -a DOTFILES_TO_LINK=(
  "gitignore_global:.gitignore_global"
  "gitmessage:.gitmessage"
  "git_template:.git_template"
  "vimrc:.vimrc"
  "vimrc.bundles:.vimrc.bundles"
  "vim:.vim"
  "aliases:.aliases"
  "tmux.conf.local:.tmux.conf.local"
  "zsh:.zsh"
  "gitconfig.local:.gitconfig.local"
  "zshrc.local:.zshrc.local"
  "zshenv.local:.zshenv.local"
)

for entry in "${DOTFILES_TO_LINK[@]}"; do
  IFS=':' read -r source target <<< "$entry"
  source_path="$DOTFILES_DIR/$source"
  target_path="$HOME/$target"

  if [ -e "$source_path" ]; then
    if [ ! -e "$target_path" ]; then
      ln -s "$source_path" "$target_path"
      success "Linked $target"
    elif [ "$(readlink "$target_path")" != "$source_path" ]; then
      warn "$target exists but doesn't point to dotfiles. Skipping."
    fi
  fi
done

# Step 10: Set up custom bin scripts
if [ -d "$DOTFILES_DIR/bin" ]; then
  log "Setting up ~/bin..."
  if [ ! -d "$HOME/bin" ]; then
    ln -s "$DOTFILES_DIR/bin" "$HOME/bin"
    success "Linked ~/bin"
  else
    info "~/bin already exists"
  fi
fi

# Final steps
echo ""
success "🎉 Bootstrap complete!"
echo ""
info "Next steps:"
info "1. Edit $SCRIPT_DIR/local.nix to customize for this machine"
info "2. Run 'sudo darwin-rebuild switch --flake /etc/nix-darwin#$CONFIG_NAME' to apply changes"
info "3. Restart your terminal or run 'exec zsh' to reload shell configuration"
echo ""
info "To update packages in the future:"
info "  cd $SCRIPT_DIR && nix flake update"
info "  sudo darwin-rebuild switch --flake /etc/nix-darwin#$CONFIG_NAME"
echo ""