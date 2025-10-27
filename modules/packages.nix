{ pkgs, ... }:

{
  # System-wide packages (from Brewfile)
  environment.systemPackages = with pkgs; [
    # Core utilities
    coreutils       # GNU core utilities (adds programs that ubuntu has by default)
    vim
    tmux
    
    # CLI Tools from Brewfile
    awscli          # AWS CLI
    # dotenvx       # TODO: Not in nixpkgs, needs custom derivation or use from npm
    # rcm           # rc manager - may not be needed with nix
    # mackup        # backup/restore osx settings - consider using home-manager instead
    # aircrack-ng   # Wireless testing
    # s5cmd         # TODO: Add if available or build from source
    
    # Development tools
    go              # Golang
    nodejs          # Node.js (replaces nvm)
    # python3       # Python
    # docker        # Handled as app/cask below
    kubectl
    
    # Version control & utilities
    git
    gh              # GitHub CLI
    direnv          # Directory-based environment management
    
    # Terminal enhancements
    ripgrep         # Fast grep alternative
    fd              # Fast find alternative
    bat             # Cat with syntax highlighting
    eza             # Modern ls replacement
    htop            # Process viewer
    jq              # JSON processor
    
    # Additional useful tools
    wget
    curl
    tree
    watch
  ];

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
      "dotenvx"       # Universal dotenv
      "rcm"           # RC file manager (if still needed)
      "mackup"        # Backup/restore settings
      "aircrack-ng"   # Wireless tools
      "peak/tap/s5cmd" # Fast S3 CLI
    ];
    
    # macOS applications (casks)
    casks = [
      # Development
      "docker"
      "visual-studio-code"
      "warp"
      "tableplus"         # Database GUI
      
      # Browsers & Communication
      "google-chrome"
      "slack"
      
      # Productivity
      "1password"
      "1password-cli"
      "rectangle"         # Window manager
      "maccy"             # Clipboard history
      "notion"
      "figma"
      "chatgpt"
      
      # Utilities
      "tailscale"
      "dropbox"
      "karabiner-elements"
    ];
    
    # Fonts
    casks = [
      "font-source-code-pro"
    ];
    
    # Update Homebrew and upgrade packages on activation
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";  # Remove old versions
    };
  };

  # Enable system-wide programs
  programs = {
    zsh.enable = true;  # Default shell
  };
}
