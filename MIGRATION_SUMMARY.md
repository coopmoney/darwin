# Migration Summary: Dotfiles → Nix-Darwin

## What Was Created

A complete nix-darwin configuration has been created in `~/dotfiles/darwin/` with the following structure:

```
~/dotfiles/darwin/
├── flake.nix                 # Main configuration entry point
├── home.nix                  # Home-manager user configuration
├── bootstrap.sh              # Automated setup script (executable)
├── local.nix.example         # Template for machine-specific overrides
├── .gitignore                # Git ignore rules
├── README.md                 # Full documentation
├── QUICKSTART.md             # Quick start guide
├── MIGRATION_SUMMARY.md      # This file
└── modules/
    ├── packages.nix          # Package management (from Brewfile)
    ├── git.nix               # Git configuration (from gitconfig)
    ├── tmux.nix              # Tmux configuration (from tmux.conf)
    ├── zsh.nix               # Zsh & aliases (from zshrc, aliases)
    ├── macos-defaults.nix    # System preferences (from macos script)
    └── fonts.nix             # Font management
```

## What Was Migrated

### ✅ Completed Migrations

1. **Brewfile → packages.nix**
   - CLI tools: coreutils, awscli, golang, nodejs, direnv, etc.
   - Applications: Docker, VS Code, Warp, Chrome, Slack, 1Password, etc.
   - Fonts: Source Code Pro
   - Hybrid approach: Nix for most packages, Homebrew for specialized tools

2. **gitconfig → git.nix**
   - All aliases (aa, ap, branches, ci, co, pf, st)
   - Git settings (editor, excludesfile, gpg signing with 1Password)
   - Git LFS configuration
   - Support for local overrides via ~/.gitconfig.local

3. **tmux.conf → tmux.nix**
   - Vi mode keybindings
   - Custom prefix (Ctrl-s)
   - Status bar styling
   - Copy-paste integration with macOS
   - Scrollback settings

4. **aliases + zshrc → zsh.nix**
   - All shell aliases (ls, ll, cd shortcuts, docker shortcuts)
   - Custom function loading from ~/.zsh/
   - Direnv integration
   - Support for local overrides via ~/.zshrc.local

5. **macos script → macos-defaults.nix**
   - Dock settings (size, minimize effect, autohide)
   - Finder preferences (show extensions, path bar, status bar)
   - Keyboard settings (repeat rate, disable press-and-hold)
   - Trackpad settings (tap to click, disable natural scrolling)
   - System preferences (disable autocorrect, smart quotes, etc.)

6. **Fonts → fonts.nix**
   - Source Code Pro via nixpkgs
   - Easy to extend with more fonts

### 📝 Still Using Original Dotfiles (Symlinked)

These files remain in `~/dotfiles/` and are symlinked by bootstrap.sh:
- `~/.vimrc` and `~/.vimrc.bundles` (vim configuration)
- `~/.aliases` (additional aliases if needed)
- `~/.zsh/` directory (custom functions and configs)
- `~/bin/` scripts (custom utilities)
- `~/.gitignore_global`
- `~/.gitmessage`
- `~/.git_template/`

These can be gradually migrated to home-manager if desired.

## How to Test

### On Your Current Machine

1. Review the configuration:
   ```bash
   cd ~/dotfiles/darwin
   cat flake.nix
   cat modules/packages.nix
   # Review other modules as needed
   ```

2. Check for syntax errors:
   ```bash
   nix flake check ~/dotfiles/darwin
   ```

3. Test build without applying:
   ```bash
   sudo darwin-rebuild build --flake ~/dotfiles/darwin#Coopers-MacBook-Pro
   ```

4. Apply the configuration:
   ```bash
   sudo darwin-rebuild switch --flake ~/dotfiles/darwin#Coopers-MacBook-Pro
   ```

### On a Fresh Machine

1. Clone your dotfiles:
   ```bash
   git clone https://github.com/coopermaruyama/dotfiles.git ~/dotfiles
   ```

2. Run bootstrap:
   ```bash
   cd ~/dotfiles/darwin
   ./bootstrap.sh
   ```

## Advantages Over Previous Setup

### Before (Brewfile + Shell Scripts)
- ❌ Imperative setup (`brew install`, manual configuration)
- ❌ No easy rollback
- ❌ Configuration drift between machines
- ❌ Manual dependency management
- ❌ Hard to reproduce exact state

### After (Nix-Darwin)
- ✅ Declarative configuration (describe desired state)
- ✅ Atomic rollbacks (`darwin-rebuild --rollback`)
- ✅ Reproducible builds (same config = same result)
- ✅ Automatic dependency management
- ✅ Version pinning via flake.lock
- ✅ Easy testing (`build` before `switch`)
- ✅ Modular organization
- ✅ Machine-specific overrides without code duplication

## Next Steps

### 1. Commit to Git (Recommended)

```bash
cd ~/dotfiles
git add darwin/
git commit -m "Add nix-darwin configuration"
git push
```

### 2. Test on Current Machine

```bash
cd ~/dotfiles/darwin
nix flake check
sudo darwin-rebuild switch --flake .#Coopers-MacBook-Pro
```

### 3. Customize for Your Needs

- Edit `modules/packages.nix` to add/remove packages
- Adjust `modules/macos-defaults.nix` for your preferred system settings
- Create `local.nix` for machine-specific config

### 4. Optional: Test in VM

If you have access to a macOS VM (UTM, Parallels), test the bootstrap script end-to-end.

### 5. Document Any Issues

If you encounter any problems during testing, note them and adjust the configuration.

## Hybrid Approach

This configuration uses both Nix and Homebrew:

**Use Nix for:**
- CLI development tools
- Programming languages
- Version-pinned dependencies
- Things you want reproducible across machines

**Use Homebrew for:**
- macOS GUI applications not in nixpkgs
- Specialized tools with complex dependencies
- Apps that update frequently and need latest version

## Customization Examples

### Add a Package

Edit `modules/packages.nix`:
```nix
environment.systemPackages = with pkgs; [
  # ... existing packages ...
  postgresql  # Add this
];
```

### Override Git Email Per Machine

Create `local.nix`:
```nix
{ ... }:
{
  programs.git.userEmail = "work@example.com";
}
```

### Change Dock Size

Edit `modules/macos-defaults.nix`:
```nix
system.defaults.dock.tilesize = 48;  # Change from 36
```

## Troubleshooting

### Common Issues

1. **"darwin-rebuild not found"**
   - Run: `. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh`
   - Or restart your terminal

2. **Syntax errors in Nix files**
   - Check with: `nix flake check ~/dotfiles/darwin`
   - Look for missing semicolons, brackets, or quotes

3. **Homebrew conflicts**
   - Remove Homebrew packages that conflict: `brew uninstall <package>`
   - Let nix-darwin manage them instead

4. **Permission errors**
   - Make sure to use `sudo` with `darwin-rebuild`

## Resources

- [Nix-Darwin Options Search](https://daiderd.com/nix-darwin/manual/index.html#sec-options)
- [Nix Package Search](https://search.nixos.org/packages)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.html)
- [Determinate Systems Docs](https://docs.determinate.systems/)

## Questions?

Check the [README.md](README.md) for full documentation or file an issue in your dotfiles repository.