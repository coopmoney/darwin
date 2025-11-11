# Darwin Nix Configuration

This repository contains my personal nix-darwin and home-manager configurations for macOS, managed through Nix Flakes. The structure is inspired by [AlexNabokikh/nix-config](https://github.com/AlexNabokikh/nix-config) and designed to be modular and easily extensible.

## Structure

```
.
├── flake.nix                 # Main flake configuration
├── flake.lock               # Lock file for reproducible builds
├── hosts/                   # Machine-specific configurations
│   └── macbook-pro/        # Configuration for MacBook Pro
├── home/                    # User-specific home-manager configs
│   └── coopermaruyama/
│       └── macbook-pro/    # User config for specific machine
├── modules/                 # Reusable modules
│   ├── darwin/             # Darwin (macOS) system modules
│   │   └── common/         # Common system configuration
│   └── home-manager/       # Home-manager modules
│       ├── common/         # Common home configuration
│       ├── misc/           # Miscellaneous configs (XDG, themes)
│       ├── programs/       # Application configurations
│       └── services/       # Service configurations
├── config/                  # Legacy config files (to be migrated)
├── dotfiles/               # Legacy dotfiles (to be migrated)
└── zsh/                    # Zsh configs and functions
```

## Key Features

- **Modular Design**: Separate modules for system (darwin) and user (home-manager) configurations
- **Multi-machine Support**: Easy to add new machines with different configurations
- **Catppuccin Theme**: Integrated Catppuccin theme support across applications
- **Declarative Package Management**: All packages defined in Nix, with Homebrew for casks
- **Comprehensive Shell Setup**: Zsh with Oh-My-Zsh, Powerlevel10k, and custom functions
- **Developer Tools**: Pre-configured git, tmux, alacritty, fzf, and more

## Modules

### Darwin Modules
- **common**: System packages, Homebrew setup, macOS defaults, fonts

### Home-Manager Modules
- **alacritty**: Terminal emulator with Catppuccin theme
- **bat**: Better `cat` with syntax highlighting
- **direnv**: Directory-based environment management
- **fzf**: Fuzzy finder with custom functions
- **git**: Version control with delta integration
- **go**: Go development environment
- **lazygit**: Terminal UI for git
- **starship**: Cross-shell prompt
- **tmux**: Terminal multiplexer with plugins
- **zsh**: Shell configuration with completions and aliases

## Usage

### Building the Configuration

```bash
# Build and switch to the new configuration
darwin-rebuild switch --flake .#Coopers-MacBook-Pro

# Or use the provided rebuild command in the dev shell
nix develop
darwin-rebuild
```

### Adding a New Machine

1. Create a new host configuration in `hosts/<machine-name>/default.nix`
2. Create a user configuration in `home/<username>/<machine-name>/default.nix`
3. Add the machine to `flake.nix` under `darwinConfigurations`
4. Build with `darwin-rebuild switch --flake .#<machine-name>`

### Modifying Configuration

- System-wide changes: Edit modules in `modules/darwin/`
- User-specific changes: Edit modules in `modules/home-manager/`
- Machine-specific overrides: Edit the machine's host or home configuration

## Development

Enter the development shell for access to formatting and linting tools:

```bash
nix develop
```

Format all Nix files:

```bash
nix fmt
```

## Migration Status

The configuration has been refactored from a flat structure to a modular one. Most dotfiles have been migrated to Nix modules, but some legacy configurations remain in the `config/`, `dotfiles/`, and `zsh/` directories for reference.

## License

This configuration is provided as-is for reference and learning purposes.