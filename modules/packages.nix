{ pkgs, flox, ... }:

{
  # System-wide packages (from Brewfile)
  environment.systemPackages = with pkgs; [
    flox.packages.${pkgs.system}.default
    # Core utilities
    coreutils # GNU core utilities (adds programs that ubuntu has by default)
    vim
    tmux

    # CLI Tools from Brewfile
    awscli2 # AWS CLI
    # dotenvx       # TODO: Not in nixpkgs, needs custom derivation or use from npm
    # rcm           # rc manager - may not be needed with nix
    # mackup        # backup/restore osx settings - consider using home-manager instead
    # aircrack-ng   # Wireless testing
    # s5cmd         # TODO: Add if available or build from source
    chamber

    # Development tools
    go # Golang
    nodejs # Node.js (replaces nvm)
    # python3       # Python
    # docker        # Handled as app/cask below
    kubectl
    biome
    aws-vault
    terraform

    # Version control & utilities
    git
    gh # GitHub CLI
    direnv # Directory-based environment management

    # Terminal enhancements
    ripgrep # Fast grep alternative
    fd # Fast find alternative
    bat # Cat with syntax highlighting
    eza # Modern ls replacement
    htop # Process viewer
    jq # JSON processor

    # Additional useful tools
    wget
    curl
    tree
    watch
  ];

  #
  #   ==> Formulae
  # aircrack-ng		openssl@3	python@3.14	readline	sqlite		zstd
  # ca-certificates	lz4		mpdecimal	pcre		rcm		s5cmd		xz

  # ==> Casks
  # 1password				notion
  # 1password-cli					noun-project			tailscale-app
  # chatgpt					postman				tor-browser
  # docker-desktop				google-chrome			rectangle			visual-studio-code
  # dropbox				karabiner-elements		slack				warp
  # figma					maccy				spotify				zerotier-one
  #	mitmproxy			stats
  # Homebrew for packages not available in nixpkgs
  # This allows a hybrid approach where needed
  homebrew = {
    enable = true;

    # Taps
    taps = [
      "dotenvx/brew"
      "peak/tap"
    ];

    # Brew formulas that aren't in nixpkgs yet
    brews = [
      "dotenvx" # Universal dotenv
      "rcm" # RC file manager (if still needed)
      "mackup" # Backup/restore settings
      "aircrack-ng" # Wireless tools
      "peak/tap/s5cmd" # Fast S3 CLI
    ];

    # macOS applications (casks) and Fonts
    casks = [
      # Development
      "docker"
      "visual-studio-code"
      "cursor"
      "warp"
      "tableplus" # Database GUI

      # Browsers & Communication
      "google-chrome"
      "slack"

      # Productivity
      "1password"
      "1password-cli"
      "rectangle" # Window manager
      "maccy" # Clipboard history
      "notion"
      "figma"
      "chatgpt"

      # Utilities
      "tailscale"
      "dropbox"
      "karabiner-elements"

      # Fonts
      "font-source-code-pro"
      "font-courier-prime"
      "font-monaspace-nerd-font"
      "font-monaspace"
      "font-geist-mono"
      "font-meslo-lg-nerd-font"
    ];

    # Update Homebrew and upgrade packages on activation
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "uninstall"; # Remove old versions (less aggressive than zap)
    };
  };

  # Enable system-wide programs
  programs = {
    zsh.enable = true; # Default shell
  };
}
