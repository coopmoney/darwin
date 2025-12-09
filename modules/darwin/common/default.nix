{
  config,
  pkgs,
  lib,
  inputs,
  name,
  ...
}:

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
  # Only include keys permitted by the Determinate module.
  determinate-nix.customSettings = {
    eval-cores = 0;
    extra-experimental-features = [
      "build-time-fetch-tree"
      "parallel-eval"
    ];
    # Note: ssl-cert-file is managed by the installer/system and is not allowed here.
    # If needed, set it in /etc/nix/nix.conf (our bootstrap does this) rather than via customSettings.
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System-wide packages
  environment.systemPackages = with pkgs; [
    # Core utilities
    cacert
    coreutils
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
    # inputs.flox.packages.${pkgs.system}.default

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
    ollama
		discord

    # Darwin rebuild utilities
    (pkgs.writeShellScriptBin "darwin" ''
      #!/usr/bin/env bash
      set -e

      FLAKE_DIR="/Users/${name}/darwin"
      SYSTEM_NAME=$(scutil --get ComputerName)

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

      # Determine flake attribute from config file or current hostname
      HOST_FILE="''${XDG_CONFIG_HOME:-$HOME/.config}/darwin/host"
      if [ -f "$HOST_FILE" ]; then
        HOST_ATTR=$(sed -e 's/[[:space:]]*$//' "$HOST_FILE")
      else
        HOST_ATTR=$(scutil --get HostName 2>/dev/null || hostname -s)
        if [ -z "$HOST_ATTR" ]; then
          HOST_ATTR=$(scutil --get LocalHostName 2>/dev/null || hostname)
        fi
      fi

      case "$COMMAND" in
        build)
          echo -e "''${YELLOW}🔨 Building configuration...''${NC}"
          darwin-rebuild build --flake ".#$HOST_ATTR" "$@"
          ;;
        switch)
          echo -e "''${YELLOW}🚀 Switching configuration...''${NC}"
          sudo darwin-rebuild switch --flake ".#$HOST_ATTR" "$@"
          ;;
        check)
          echo -e "''${YELLOW}🔍 Checking configuration...''${NC}"
          darwin-rebuild check --flake ".#$HOST_ATTR" "$@"
          ;;
        *)
          echo -e "''${RED}Unknown command: $COMMAND''${NC}"
          echo ""
          echo "Usage: darwin [command] [options]"
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
    (pkgs.writeShellScriptBin "osxup" ''
      #!/usr/bin/env bash
      exec darwin switch "$@"
    '')

    (pkgs.writeShellScriptBin "darwinup" ''
      #!/usr/bin/env bash
      exec darwin switch "$@"
    '')


    (pkgs.writeShellScriptBin "drbc" ''
      #!/usr/bin/env bash
      exec osxup check "$@"
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
    EDITOR = "nvim";
    VISUAL = "nvim";
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

        nativeBuildInputs = [
          pkgs.nodejs
          pkgs.python3
        ];

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
      "docker-desktop"
      "visual-studio-code"
      "cursor"
      "warp"
      "tableplus"
      "plex-media-server"
			"plex"

      # Browsers & Communication
      "google-chrome"
      "slack"

      # Productivity
      "1password"
      "1password-cli"
      "rectangle"
      "raycast"
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
      "font-monaspice-nerd-font"
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
      # Show indicator lights for open applications
      show-process-indicators = true;
      # Minimize windows into application icon
      launchanim = true;
      # Make hidden apps translucent in Dock
      showhidden = false;
      # Don't automatically rearrange Spaces based on most recent use
      mru-spaces = false;
      # Speed up Mission Control animations
      expose-animation-duration = 0.1;
      # Wipe all app icons from the Dock (can be customized per machine)
      # persistent-apps = [];
    };

    # Finder
    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      ShowStatusBar = true;
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "clmv"; # Column view
      _FXSortFoldersFirst = true;
      # Show hidden files
      AppleShowAllFiles = false;
      # Allow quitting Finder via ⌘ + Q
      QuitMenuItem = false;
      # Default search scope: This Mac
      FXDefaultSearchScope = "SCsp"; # "SCcf" = This Mac, "SCsp" = Current Folder
      # Show full POSIX path in window title
      _FXShowPosixPathInTitle = false;
      # Disable icons on the desktop
      CreateDesktop = true;
    };

    # Trackpad
    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
      TrackpadThreeFingerDrag = true;
      # Light, medium, or firm click (0, 1, 2)
      FirstClickThreshold = 1;
      SecondClickThreshold = 1;
      # Enable tap to click for login screen
      ActuateDetents = true;
    };

    # Screenshots
    screencapture = {
      # Save screenshots to Downloads folder
      location = "~/Downloads";
      # Screenshot format: png, jpg, pdf, tiff, bmp, gif
      type = "png";
      # Disable shadow in screenshots
      disable-shadow = false;
      # Show thumbnail after taking screenshot
      show-thumbnail = true;
    };

    # Login Window
    loginwindow = {
      # Disable guest account
      GuestEnabled = false;
      # Show name instead of username
      SHOWFULLNAME = false;
      # Disable auto login
      autoLoginUser = null;
      # Text shown on login window
      LoginwindowText = null;
      # Disable restart/shutdown buttons
      PowerOffDisabledWhileLoggedIn = false;
      RestartDisabledWhileLoggedIn = false;
      ShutDownDisabledWhileLoggedIn = false;
    };

    # Menu Bar Clock
    menuExtraClock = {
      # Show date in menu bar clock
      ShowDate = 0; # 0 = When space allows, 1 = Always, 2 = Never
      # Show day of week
      ShowDayOfWeek = true;
      # Show AM/PM
      Show24Hour = false;
      # Show seconds
      ShowSeconds = false;
      # Flash date/time separators
      FlashDateSeparators = false;
      # Analog or digital
      IsAnalog = false;
    };

    # Activity Monitor
    ActivityMonitor = {
      # Show all processes
      ShowCategory = 100;
      # Sort by CPU usage
      SortColumn = "CPUUsage";
      SortDirection = 0;
      # Icon type: 5 = CPU Usage, 6 = CPU History
      IconType = 5;
      # Show main window on launch
      OpenMainWindow = true;
    };

    # Spaces (Mission Control)
    spaces = {
      # Group windows by application in Mission Control
      spans-displays = true;
    };

    # Universal Access / Accessibility
    # universalaccess = {
    #   # Reduce transparency
    #   reduceTransparency = false;
    #   # Reduce motion
    #   reduceMotion = false;
    #   # Close windows on quit
    #   closeViewScrollWheelToggle = false;
    #   # Mouse cursor size (1.0 to 4.0)
    #   mouseDriverCursorSize = 1.0;
    # };

    # Launch Services (default apps)
    LaunchServices = {
      # Disable quarantine for downloaded apps
      LSQuarantine = true;
    };

    # Screen Saver
    screensaver = {
      # Require password after sleep or screen saver
      askForPassword = true;
      # Delay before password is required (in seconds)
      askForPasswordDelay = 5;
    };

    # SMB/File Sharing
    smb = {
      # Disable SMB server signing (for performance)
      NetBIOSName = null;
      ServerDescription = null;
    };

    # Global macOS Settings
    NSGlobalDomain = {
      # Dark mode
      AppleInterfaceStyle = "Dark";
      AppleShowAllExtensions = true;
      AppleShowScrollBars = "WhenScrolling";

      # Keyboard
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      ApplePressAndHoldEnabled = false; # Disable accent picker to enable key repeat
      KeyRepeat = 2; # Fast key repeat (2 = 30ms)
      InitialKeyRepeat = lib.mkDefault 10;
      NSWindowResizeTime = 0.001;

      # Save & Print Panels
      # Expand save panel by default
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
      # Expand print panel by default
      PMPrintingExpandedStateForPrint = true;
      PMPrintingExpandedStateForPrint2 = true;
      # Save to disk (not iCloud) by default
      NSDocumentSaveNewDocumentsToCloud = false;

      # Text & Editing
      # Show control characters
      NSTextShowsControlCharacters = false;
      # Use animated focus ring
      NSUseAnimatedFocusRing = true;

      # Measurements & Units
      AppleMeasurementUnits = "Centimeters";
      AppleMetricUnits = 1; # Use metric
      AppleTemperatureUnit = "Celsius";

      # Sound
      # Alert volume (0.0 to 1.0)
      "com.apple.sound.beep.volume" = 0.5;
      # Play feedback when volume changed
      "com.apple.sound.beep.feedback" = 0;

      # Sidebar icon size
      NSTableViewDefaultSizeMode = 2; # 1 = Small, 2 = Medium, 3 = Large
    };

    # Custom User Preferences (for settings not exposed by nix-darwin)
    CustomUserPreferences = {
      # Disable Time Machine prompts for new disks
      "com.apple.TimeMachine" = {
        DoNotOfferNewDisksForBackup = true;
      };

      # Disable disk image verification
      "com.apple.frameworks.diskimages" = {
        skip-verify = true;
        skip-verify-locked = true;
        skip-verify-remote = true;
      };

      # Safari preferences can't be set via nix-darwin due to sandboxing.
      # To enable these manually, open Safari and go to:
      # - Safari > Settings > Advanced > Show features for web developers

      # TextEdit: Use plain text mode by default
      "com.apple.TextEdit" = {
        RichText = 0;
      };

      # Disable Spotlight
      "com.apple.spotlight" = {
        orderedItems = [
          {
            enabled = 0;
            name = "APPLICATIONS";
          }
          {
            enabled = 0;
            name = "MENU_SPOTLIGHT_SUGGESTIONS";
          }
          {
            enabled = 0;
            name = "MENU_CONVERSION";
          }
          {
            enabled = 0;
            name = "MENU_EXPRESSION";
          }
          {
            enabled = 0;
            name = "MENU_DEFINITION";
          }
          {
            enabled = 0;
            name = "SYSTEM_PREFS";
          }
          {
            enabled = 0;
            name = "DOCUMENTS";
          }
          {
            enabled = 0;
            name = "DIRECTORIES";
          }
          {
            enabled = 0;
            name = "PRESENTATIONS";
          }
          {
            enabled = 0;
            name = "SPREADSHEETS";
          }
          {
            enabled = 0;
            name = "PDF";
          }
          {
            enabled = 0;
            name = "MESSAGES";
          }
          {
            enabled = 0;
            name = "CONTACT";
          }
          {
            enabled = 0;
            name = "EVENT_TODO";
          }
          {
            enabled = 0;
            name = "IMAGES";
          }
          {
            enabled = 0;
            name = "BOOKMARKS";
          }
          {
            enabled = 0;
            name = "MUSIC";
          }
          {
            enabled = 0;
            name = "MOVIES";
          }
          {
            enabled = 0;
            name = "FONTS";
          }
          {
            enabled = 0;
            name = "MENU_OTHER";
          }
        ];
      };

      # Raycast preferences
      "com.raycast.macos" = {
        # Show in menu bar
        showInMenuBar = true;

        # Initial setup completed
        initialSpotlightSetupCompleted = true;

        # Analytics
        analyticsEnabled = false;
        crashReportingEnabled = false;

        # Appearance
        emojiPickerSkinTone = 0; # Default skin tone

        # Window behavior
        popToRootTimeout = 60;

        # Navigation
        navigationCommandStyleIdentifierKey = "default";

        # Other
        keepHistoryInClipboard = true;
        clipboardHistoryLength = 100;
        windowWidth = 680;
        "NSStatusItem Preferred Position Item-0" = 0.0;

        # Privacy
        "raycast-telemetry" = false;
      };
    };
  };

  # System keyboard remapping
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };

  # Touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  # User-level launchd agent for Ollama
  launchd.user.agents."dev.ollama.user" = {
    serviceConfig = {
      ProgramArguments = [ "${pkgs.ollama}/bin/ollama" "serve" ];
      RunAtLoad = true;
      KeepAlive = true;
      EnvironmentVariables = {
        OLLAMA_HOST = "127.0.0.1:11434";
        OLLAMA_MODELS = "/Users/${name}/.local/share/ollama/models";
      };
      StandardOutPath = "/Users/${name}/.local/state/ollama/ollama.out.log";
      StandardErrorPath = "/Users/${name}/.local/state/ollama/ollama.err.log";
    };
  };
}
