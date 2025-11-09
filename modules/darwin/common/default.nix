{ config, pkgs, lib, inputs, name, ... }:

{
  # Required for nix-darwin
  system.stateVersion = 1;

  # Primary user configuration
  system.primaryUser = name;
  users.users.${name} = {
    name = name;
    home = "/Users/${name}";
  };

  # Nix configuration
  nix = {
    enable = false; # Let Determinate handle this
    # settings = {
    #   experimental-features = [ "nix-command" "flakes" ];
    # };
  };

  # Determinate Nix settings
  determinate-nix.customSettings = {
    eval-cores = 0;
    extra-experimental-features = [
      "build-time-fetch-tree"
      "parallel-eval"
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System-wide packages
  environment.systemPackages = with pkgs; [
    # Core utilities
    coreutils
    vim
    tmux
    git
    curl
    wget
    tree
    watch

    # CLI Tools
    awscli2
    chamber

    # Development tools
    go
    nodejs
    kubectl
    biome
    aws-vault
    terraform
    gh
    direnv

    # Terminal enhancements
    ripgrep
    fd
    bat
    eza
    htop
    jq

    # Additional tools
    act
    alacritty
    stats
    lazygit
    postgresql
  ];

  # Environment variables
  environment.variables = {
    EDITOR = "vim";
    VISUAL = "vim";
  };

  # Fonts configuration
  fonts = {
    packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.meslo-lg
      nerd-fonts.jetbrains-mono
      fira-code
      jetbrains-mono
      roboto
    ];
  };

  # Homebrew configuration
  homebrew = {
    enable = true;

    taps = [
      "dotenvx/brew"
      "peak/tap"
    ];

    brews = [
      "dotenvx"
      "rcm"
      "mackup"
      "aircrack-ng"
      "peak/tap/s5cmd"
    ];

    casks = [
      # Development
      "docker"
      "visual-studio-code"
      "cursor"
      "warp"
      "tableplus"

      # Browsers & Communication
      "google-chrome"
      "slack"

      # Productivity
      "1password"
      "1password-cli"
      "rectangle"
      "maccy"
      "notion"
      "figma"
      "chatgpt"
      "claude"

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

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "uninstall";
    };
  };

  # Enable zsh
  programs.zsh.enable = true;
  environment.shells = [ pkgs.zsh ];

  # macOS defaults
  system.defaults = {
    # Dock
    dock = {
      autohide = true;
      minimize-to-application = true;
      show-recents = false;
      tilesize = 48;
      largesize = 64;
      magnification = true;
    };

    # Finder
    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      ShowStatusBar = true;
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "clmv";
      _FXSortFoldersFirst = true;
    };

    # Trackpad
    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
      TrackpadThreeFingerDrag = true;
    };

    # Global
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleShowAllExtensions = true;
      AppleShowScrollBars = "WhenScrolling";
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      "com.apple.keyboard.fnState" = true;
      "com.apple.trackpad.scaling" = 3.0;
    };
  };

  # System keyboard remapping
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };

  # Touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;
}
