# Nix-Darwin Configuration

This directory contains a declarative macOS system configuration using [nix-darwin](https://github.com/LnL7/nix-darwin) and [home-manager](https://github.com/nix-community/home-manager).

## What This Does

This configuration replaces:
- ✅ **Homebrew Brewfile** → Nix packages + selective Homebrew integration
- ✅ **Git configuration** → Declarative git settings
- ✅ **Tmux configuration** → Managed tmux setup
- ✅ **Zsh configuration** → Shell aliases and environment
- ✅ **macOS defaults** → System preferences as code
- ✅ **Manual setup** → One command to bootstrap a new machine

## Quick Start

### Fresh Machine Setup

1. Clone your dotfiles repository:
   ```bash
   git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
   cd ~/dotfiles/darwin
   ```

2. Run the bootstrap script:
   ```bash
   chmod +x bootstrap.sh
   ./bootstrap.sh
   ```

3. The script will:
   - Install Xcode Command Line Tools (if needed)
   - Install Determinate Systems Nix
   - Install nix-darwin
   - Apply your system configuration
   - Symlink remaining dotfiles
   - Set up your development environment

4. Restart your terminal or run:
   ```bash
   exec zsh
   ```

### Existing Machine

If you already have Nix and nix-darwin installed:

```bash
sudo darwin-rebuild switch --flake ~/dotfiles/darwin#Coopers-MacBook-Pro
```

## Configuration Structure

```
darwin/
├── flake.nix              # Main entry point
├── home.nix               # Home-manager user configuration
├── bootstrap.sh           # Setup script for new machines
├── local.nix.example      # Template for machine-specific overrides
├── local.nix              # Machine-specific config (gitignored)
└── modules/
    ├── packages.nix       # System packages (from Brewfile)
    ├── git.nix            # Git configuration
    ├── tmux.nix           # Tmux configuration
    ├── zsh.nix            # Zsh configuration
    ├── macos-defaults.nix # macOS system preferences
    └── fonts.nix          # Font management
```

## Customization

### Machine-Specific Settings

Copy `local.nix.example` to `local.nix` and customize:

```nix
{ pkgs, ... }:

{
  # Override git user for this machine
  programs.git = {
    userName = "Your Name";
    userEmail = "your.email@company.com";
  };
  
  # Add machine-specific packages
  environment.systemPackages = with pkgs; [
    # your packages here
  ];
}
```

### Adding Packages

Edit `modules/packages.nix`:

```nix
environment.systemPackages = with pkgs; [
  # Add new packages here
  ripgrep
  fd
  neovim
];
```

### Adding Applications

For GUI apps, use Homebrew casks in `modules/packages.nix`:

```nix
homebrew.casks = [
  "visual-studio-code"
  "slack"
  # Add more apps here
];
```

## Common Tasks

### Update All Packages

```bash
cd ~/dotfiles/darwin
nix flake update
sudo darwin-rebuild switch --flake .#Coopers-MacBook-Pro
```

### Test Configuration Without Applying

```bash
sudo darwin-rebuild build --flake ~/dotfiles/darwin#Coopers-MacBook-Pro
```

### Check Configuration for Errors

```bash
nix flake check ~/dotfiles/darwin
```

### Rollback to Previous Generation

```bash
sudo darwin-rebuild --rollback
```

### List Generations

```bash
darwin-rebuild --list-generations
```

### Add a New Machine

1. Edit `flake.nix` and add a new configuration:
   ```nix
   darwinConfigurations = {
     "Coopers-MacBook-Pro" = mkDarwinSystem "Coopers-MacBook-Pro" "aarch64-darwin";
     "Work-MacBook" = mkDarwinSystem "Work-MacBook" "aarch64-darwin";
   };
   ```

2. On the new machine, run:
   ```bash
   ./bootstrap.sh
   ```

## Migrating from Homebrew

This configuration uses a hybrid approach:
- **Nix packages** for most CLI tools and some GUI apps
- **Homebrew casks** for GUI apps not available in Nix
- **Homebrew formulas** for a few specialized tools

To see what's installed via Homebrew:
```bash
brew list
```

To see what's installed via Nix:
```bash
nix-env -q
```

## Troubleshooting

### "darwin-rebuild not found"

Make sure nix-darwin is installed and sourced:
```bash
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

### "experimental-features not enabled"

Add to `/etc/nix/nix.conf`:
```
experimental-features = nix-command flakes
```

### Changes not applying

1. Check syntax:
   ```bash
   nix flake check ~/dotfiles/darwin
   ```

2. Rebuild with verbose output:
   ```bash
   sudo darwin-rebuild switch --flake ~/dotfiles/darwin#Coopers-MacBook-Pro --show-trace
   ```

### Homebrew conflicts

If Homebrew packages conflict with Nix:
1. Uninstall the Homebrew package: `brew uninstall <package>`
2. Let nix-darwin manage it instead

## Philosophy

This configuration follows these principles:

1. **Declarative over Imperative**: System state is defined in code, not built up through commands
2. **Reproducible**: Running bootstrap.sh on a new machine produces the same result
3. **Version Controlled**: All changes are tracked in Git
4. **Modular**: Each concern (git, zsh, packages) is in its own file
5. **Hybrid Approach**: Use Nix where it excels, Homebrew where necessary
6. **Machine-Specific Overrides**: `local.nix` for per-machine customization

## Resources

- [Nix-Darwin Manual](https://daiderd.com/nix-darwin/manual/index.html)
- [Nix Manual](https://nixos.org/manual/nix/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Determinate Systems Nix Installer](https://github.com/DeterminateSystems/nix-installer)
- [Nix Package Search](https://search.nixos.org/packages)

## Contributing

When making changes:

1. Test locally first:
   ```bash
   sudo darwin-rebuild switch --flake ~/dotfiles/darwin#Coopers-MacBook-Pro
   ```

2. Commit your changes:
   ```bash
   git add -A
   git commit -m "feat: add new package"
   git push
   ```

3. On other machines, pull and rebuild:
   ```bash
   cd ~/dotfiles
   git pull
   sudo darwin-rebuild switch --flake darwin#$(hostname -s)
   ```