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

    # Darwin rebuild utilities
    (pkgs.writeShellScriptBin "darwin-rebuild-here" ''
      #!/usr/bin/env bash
      set -e

      FLAKE_DIR="/Users/${name}/darwin"

      # Colors for output
      RED='\033[0;31m'
      GREEN='\033[0;32m'
      YELLOW='\033[0;33m'
      BLUE='\033[0;34m'
      NC='\033[0m' # No Color

      echo -e "''${BLUE}🔄 Darwin Rebuild Utility''${NC}"
      echo -e "''${YELLOW}Flake directory: $FLAKE_DIR''${NC}"

      # Check if flake directory exists
      if [ ! -d "$FLAKE_DIR" ]; then
        echo -e "''${RED}❌ Error: Flake directory not found at $FLAKE_DIR''${NC}"
        exit 1
      fi

      # Change to flake directory
      cd "$FLAKE_DIR"

      # Check for uncommitted changes
      if git diff-index --quiet HEAD -- 2>/dev/null; then
        echo -e "''${GREEN}✓ Git tree is clean''${NC}"
      else
        echo -e "''${YELLOW}⚠️  Warning: Git tree has uncommitted changes''${NC}"
      fi

      # Parse arguments
      COMMAND="''${1:-switch}"
      shift || true

      case "$COMMAND" in
        build)
          echo -e "''${YELLOW}🔨 Building configuration...''${NC}"
          darwin-rebuild build --flake '.#Coopers-MacBook-Pro' "$@"
          ;;
        switch)
          echo -e "''${YELLOW}🚀 Switching configuration...''${NC}"
          sudo darwin-rebuild switch --flake '.#Coopers-MacBook-Pro' "$@"
          ;;
        check)
          echo -e "''${YELLOW}🔍 Checking configuration...''${NC}"
          darwin-rebuild check --flake '.#Coopers-MacBook-Pro' "$@"
          ;;
        *)
          echo -e "''${RED}Unknown command: $COMMAND''${NC}"
          echo ""
          echo "Usage: darwin-rebuild-here [command] [options]"
          echo ""
          echo "Commands:"
          echo "  build   - Build the configuration without switching"
          echo "  switch  - Build and switch to the new configuration (default)"
          echo "  check   - Check the configuration for errors"
          echo ""
          echo "All additional arguments are passed to darwin-rebuild"
          exit 1
          ;;
      esac
    '')

    # Shortcut commands
    (pkgs.writeShellScriptBin "drb" ''
      #!/usr/bin/env bash
      exec darwin-rebuild-here "$@"
    '')

    (pkgs.writeShellScriptBin "drbs" ''
      #!/usr/bin/env bash
      exec darwin-rebuild-here switch "$@"
    '')

    (pkgs.writeShellScriptBin "drbb" ''
      #!/usr/bin/env bash
      exec darwin-rebuild-here build "$@"
    '')

    (pkgs.writeShellScriptBin "drbc" ''
      #!/usr/bin/env bash
      exec darwin-rebuild-here check "$@"
    '')

    # Nix package search utility
    (pkgs.writeShellScriptBin "pkg?" ''
      #!/usr/bin/env bash

      # Colors for output
      RED='\033[0;31m'
      GREEN='\033[0;32m'
      YELLOW='\033[0;33m'
      BLUE='\033[0;34m'
      CYAN='\033[0;36m'
      BOLD='\033[1m'
      NC='\033[0m' # No Color

      # Function to show usage
      show_usage() {
        echo -e "''${BOLD}Usage:''${NC} pkg? [options] <search-term>"
        echo ""
        echo -e "''${BOLD}Description:''${NC}"
        echo "  Search for packages in nixpkgs using regex patterns"
        echo ""
        echo -e "''${BOLD}Examples:''${NC}"
        echo -e "  pkg? vim                # Search for packages containing 'vim'"
        echo -e "  pkg? '^vim'             # Search for packages starting with 'vim'"
        echo -e "  pkg? 'python.*jupyter'  # Search using regex pattern"
        echo -e "  pkg? -d vim             # Show detailed package info"
        echo -e "  pkg? -j vim             # Output as JSON"
        echo ""
        echo -e "''${BOLD}Options:''${NC}"
        echo "  -h, --help              Show this help message"
        echo "  -d, --detailed          Show detailed package information"
        echo "  -j, --json              Output in JSON format"
        echo "  -e, --exclude <pattern> Exclude packages matching pattern"
        echo "  -n, --number <n>        Limit results to n packages (default: 50)"
        echo ""
        echo -e "''${BOLD}Regex Examples:''${NC}"
        echo "  '^python3'              Packages starting with python3"
        echo "  'server$'               Packages ending with server"
        echo "  'node.*[0-9]+'          Node packages with version numbers"
        echo "  '(vim|emacs)'           Packages containing vim or emacs"
      }

      # Default values
      DETAILED=0
      JSON=0
      LIMIT=50
      EXCLUDE=""

      # Parse options
      while [[ $# -gt 0 ]]; do
        case $1 in
          -h|--help)
            show_usage
            exit 0
            ;;
          -d|--detailed)
            DETAILED=1
            shift
            ;;
          -j|--json)
            JSON=1
            shift
            ;;
          -e|--exclude)
            EXCLUDE="$2"
            shift 2
            ;;
          -n|--number)
            LIMIT="$2"
            shift 2
            ;;
          -*)
            echo -e "''${RED}Unknown option: $1''${NC}"
            show_usage
            exit 1
            ;;
          *)
            break
            ;;
        esac
      done

      # Check if search term provided
      if [ $# -eq 0 ]; then
        echo -e "''${RED}Error: No search term provided''${NC}"
        show_usage
        exit 1
      fi

      SEARCH_TERM="$*"

      # Build nix search command
      NIX_CMD="nix search nixpkgs"

      if [ $JSON -eq 1 ]; then
        NIX_CMD="$NIX_CMD --json"
      fi

      # Add the search term
      NIX_CMD="$NIX_CMD \"$SEARCH_TERM\""

      # Show what we're searching for
      if [ $JSON -eq 0 ]; then
        echo -e "''${BLUE}🔍 Searching nixpkgs for:''${NC} ''${YELLOW}$SEARCH_TERM''${NC}"
        echo ""
      fi

      # Execute search and process results
      if [ $JSON -eq 1 ]; then
        # JSON output
        eval "$NIX_CMD" 2>/dev/null
      else
        # Pretty output
        RESULTS=$(eval "$NIX_CMD" 2>/dev/null)

        if [ -z "$RESULTS" ]; then
          echo -e "''${YELLOW}No packages found matching '$SEARCH_TERM''\${NC}"
          exit 0
        fi

        # Process and format results
        COUNT=0
        while IFS= read -r line; do
          if [[ -z "$line" ]]; then
            continue
          fi

          # Check if this is a package name line (starts with *)
          if [[ "$line" =~ ^\*[[:space:]]+(.*) ]]; then
            PACKAGE_PATH="''${BASH_REMATCH[1]}"

            # Apply exclude filter if set
            if [[ -n "$EXCLUDE" ]] && [[ "$PACKAGE_PATH" =~ $EXCLUDE ]]; then
              continue
            fi

            # Increment counter and check limit
            ((COUNT++))
            if [ $COUNT -gt $LIMIT ]; then
              echo -e "\n''${YELLOW}Showing first $LIMIT results. Use -n to show more.''\${NC}"
              break
            fi

            # Extract package name
            PACKAGE_NAME="''${PACKAGE_PATH##*.}"

            echo -e "''${GREEN}●''${NC} ''${BOLD}$PACKAGE_NAME''${NC} ''${CYAN}($PACKAGE_PATH)''${NC}"

            if [ $DETAILED -eq 0 ]; then
              # Skip to next package description line
              read -r desc_line
              if [[ "$desc_line" =~ ^[[:space:]]+(.+) ]]; then
                echo -e "  ''${BASH_REMATCH[1]}"
              fi
              echo ""
            fi
          elif [ $DETAILED -eq 1 ] && [[ "$line" =~ ^[[:space:]]+(.+) ]]; then
            # Show all details in detailed mode
            echo -e "  ''${BASH_REMATCH[1]}"
          fi
        done <<< "$RESULTS"

        echo -e "\n''${BLUE}Found $COUNT packages''\${NC}"
      fi
    '')
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
      # Monaspace font from GitHub master branch
      (pkgs.stdenv.mkDerivation rec {
        pname = "monaspace";
        version = "master-${builtins.substring 0 7 src.rev}";

        src = pkgs.fetchFromGitHub {
          owner = "githubnext";
          repo = "monaspace";
          rev = "master";
          sha256 = "sha256-8tPwm92ZtaXL9qeDL+ay9PdXLUBBsspdk7/0U8VO0Tg=";
        };

        nativeBuildInputs = [ pkgs.nodejs pkgs.python3 ];

        buildPhase = ''
          # The fonts are pre-built in the repo
          echo "Fonts are pre-built in the repository"
        '';

        installPhase = ''
          mkdir -p $out/share/fonts/opentype
          mkdir -p $out/share/fonts/truetype
          mkdir -p $out/share/fonts/variable
          mkdir -p $out/share/fonts/woff

          # Copy Static Fonts (OTF)
          if [ -d "fonts/Static Fonts" ]; then
            find "fonts/Static Fonts" -name "*.otf" -exec cp {} $out/share/fonts/opentype/ \;
          fi

          # Copy Variable Fonts
          if [ -d "fonts/Variable Fonts" ]; then
            find "fonts/Variable Fonts" -name "*.ttf" -exec cp {} $out/share/fonts/variable/ \;
          fi

          # Copy Web Fonts
          if [ -d "fonts/Web Fonts" ]; then
            find "fonts/Web Fonts" -name "*.woff" -o -name "*.woff2" -exec cp {} $out/share/fonts/woff/ \;
          fi

          # Also check for regular TTF fonts
          find fonts -name "*.ttf" -exec cp {} $out/share/fonts/truetype/ \; 2>/dev/null || true
        '';
      })
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
