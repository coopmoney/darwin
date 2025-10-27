# Quick Start: Setting Up a New Mac

This is the TL;DR version. For full documentation, see [README.md](README.md).

## One-Command Setup

On a fresh Mac, run:

```bash
# Clone your dotfiles
git clone https://github.com/coopermaruyama/dotfiles.git ~/dotfiles

# Run bootstrap
cd ~/dotfiles/darwin
./bootstrap.sh

# Restart terminal
exec zsh
```

That's it! ✨

## What Gets Installed

- **Development Tools**: Git, Go, Node.js, AWS CLI, direnv
- **Terminal Tools**: tmux, vim, ripgrep, bat, eza, htop, jq
- **Applications**: Docker, VS Code, Warp, Chrome, Slack, 1Password, Rectangle, Notion, Figma, and more
- **Fonts**: Source Code Pro
- **System Preferences**: Keyboard repeat rate, trackpad settings, Finder preferences, Dock settings

## After Bootstrap

1. **Customize for this machine** (optional):
   ```bash
   cp ~/dotfiles/darwin/local.nix.example ~/dotfiles/darwin/local.nix
   vim ~/dotfiles/darwin/local.nix
   ```

2. **Apply changes**:
   ```bash
   sudo darwin-rebuild switch --flake ~/dotfiles/darwin#$(hostname -s)
   ```

3. **Set up 1Password SSH agent** (if you use it):
   - Open 1Password
   - Settings → Developer → Use SSH agent
   - Add your SSH key to 1Password

## Updating Packages

```bash
cd ~/dotfiles/darwin
nix flake update
sudo darwin-rebuild switch --flake .#$(hostname -s)
```

## Adding More Packages

Edit `~/dotfiles/darwin/modules/packages.nix`:

```nix
environment.systemPackages = with pkgs; [
  # Add your packages here
  postgresql
  redis
  # ...
];
```

Then rebuild:
```bash
sudo darwin-rebuild switch --flake ~/dotfiles/darwin#$(hostname -s)
```

## Troubleshooting

**Script fails?** Make sure Xcode Command Line Tools are installed:
```bash
xcode-select --install
```

**Need help?** Check the full [README.md](README.md) or file an issue.