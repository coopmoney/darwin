{ inputs, darwinModules, ... }:

{
  imports = [
    "${darwinModules}/common"
  ];

  # Machine-specific settings
  networking.hostName = "Coopers-MacBook-Pro";
  networking.computerName = "Cooper's MacBook Pro";
  networking.localHostName = "Coopers-MacBook-Pro";

  # System configuration specific to this machine
  system = {
    stateVersion = 1;

    # Default applications
    defaults = {
      # Dock Configuration
      # See: https://daiderd.com/nix-darwin/manual/index.html#opt-system.defaults.dock
      dock = {
        autohide = true;                      # default: false - Auto-hide the dock
        # autohide-delay = 0.0;               # default: 0.0 - Delay before showing dock (seconds)
        # autohide-time-modifier = 0.0;       # default: 0.0 - Animation duration (seconds)
        # dashboard-in-overlay = false;       # default: false - Show dashboard as overlay
        # enable-spring-load-actions-on-all-items = false; # default: false
        # expose-animation-duration = 0.0;    # default: 0.0
        # expose-group-by-app = false;        # default: false
        largesize = 64;                       # default: null - Icon size when magnified
        # launchanim = true;                  # default: true - Animate launching apps
        magnification = true;                 # default: false - Enable magnification
        minimize-to-application = true;       # default: false - Minimize windows into app icon
        mru-spaces = false;                   # default: true - Rearrange spaces based on most recent use
        # orientation = "bottom";             # default: "bottom" - Options: "left", "bottom", "right"
        # persistent-apps = [];               # default: [] - List of app paths to keep in dock
        # persistent-others = [];             # default: [] - List of folder paths
        show-recents = false;                 # default: true - Show recent apps
        # show-process-indicators = true;     # default: true
        # showhidden = false;                 # default: false - Make hidden apps translucent
        # static-only = false;                # default: false - Show only active apps
        tilesize = 48;                        # default: 64 - Icon size
        # wvous-bl-corner = 1;                # default: 1 - Bottom left hot corner (1=disabled)
        # wvous-br-corner = 1;                # default: 1 - Bottom right hot corner
        # wvous-tl-corner = 1;                # default: 1 - Top left hot corner
        # wvous-tr-corner = 1;                # default: 1 - Top right hot corner
      };

      # Finder Configuration
      # See: https://daiderd.com/nix-darwin/manual/index.html#opt-system.defaults.finder
      finder = {
        AppleShowAllExtensions = true;        # default: false - Show all file extensions
        # AppleShowAllFiles = false;          # default: false - Show hidden files
        # CreateDesktop = true;               # default: true - Show icons on desktop
        FXEnableExtensionChangeWarning = false; # default: true - Warn when changing extension
        # FXDefaultSearchScope = "SCcf";      # default: "SCcf" - "SCcf"=This Mac, "SCsp"=Current Folder
        FXPreferredViewStyle = "clmv";        # default: null - "icnv"=Icon, "Nlsv"=List, "clmv"=Column, "Flwv"=Gallery
        # QuitMenuItem = false;               # default: false - Show quit menu item
        ShowPathbar = true;                   # default: false - Show path bar
        ShowStatusBar = true;                 # default: false - Show status bar
        _FXSortFoldersFirst = true;           # default: false - Sort folders first
        # _FXShowPosixPathInTitle = false;    # default: false - Show full path in title
      };

      # Global macOS Settings
      # See: https://daiderd.com/nix-darwin/manual/index.html#opt-system.defaults.NSGlobalDomain
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";         # default: null - "Dark" or null for light
        # AppleInterfaceStyleSwitchesAutomatically = false; # default: false
        AppleShowAllExtensions = true;        # default: false
        # AppleShowScrollBars = "WhenScrolling"; # default: "WhenScrolling" - "Automatic", "WhenScrolling", "Always"
        # ApplePressAndHoldEnabled = true;    # default: true - Enable press-and-hold for accents
        # AppleKeyboardUIMode = 3;            # default: null - Full keyboard access (3=all controls)
        # AppleMeasurementUnits = "Centimeters"; # default: "Centimeters"
        # AppleMetricUnits = 1;               # default: 1 - Use metric
        # AppleShowAllFiles = false;          # default: false
        # AppleTemperatureUnit = "Celsius";   # default: "Celsius"
        InitialKeyRepeat = 15;                # default: 15 - Initial key repeat delay (15=225ms)
        KeyRepeat = 2;                        # default: 2 - Key repeat rate (2=30ms)
        NSAutomaticCapitalizationEnabled = false; # default: true
        NSAutomaticDashSubstitutionEnabled = false; # default: true - Smart dashes
        NSAutomaticPeriodSubstitutionEnabled = false; # default: true - Period with double space
        NSAutomaticQuoteSubstitutionEnabled = false; # default: true - Smart quotes
        NSAutomaticSpellingCorrectionEnabled = false; # default: true
        # NSDocumentSaveNewDocumentsToCloud = false; # default: false
        # NSNavPanelExpandedStateForSaveMode = true; # default: true - Expanded save panel
        # NSNavPanelExpandedStateForSaveMode2 = true; # default: true
        # NSTableViewDefaultSizeMode = 1;     # default: 1 - Sidebar icon size (1=small, 2=medium, 3=large)
        # NSTextShowsControlCharacters = false; # default: false
        # NSUseAnimatedFocusRing = true;      # default: true
        # NSScrollAnimationEnabled = true;    # default: true
        # NSWindowResizeTime = 0.2;           # default: 0.2
        # PMPrintingExpandedStateForPrint = true; # default: true - Expanded print panel
        # PMPrintingExpandedStateForPrint2 = true; # default: true
        "com.apple.keyboard.fnState" = true;  # default: false - Use F keys as standard function keys
        # "com.apple.mouse.tapBehavior" = 1;  # default: null - Enable tap to click
        "com.apple.trackpad.scaling" = 3.0;   # default: null - Tracking speed (0.0 to 3.0)
        # "com.apple.swipescrolldirection" = true; # default: true - Natural scrolling
        # "com.apple.sound.beep.volume" = 0.5; # default: null - Alert volume (0.0 to 1.0)
        # "com.apple.sound.beep.feedback" = 0; # default: 0 - Play feedback when volume changed
      };

      # Trackpad Configuration
      # See: https://daiderd.com/nix-darwin/manual/index.html#opt-system.defaults.trackpad
      trackpad = {
        Clicking = true;                      # default: false - Tap to click
        # DragLock = false;                   # default: false
        # Dragging = false;                   # default: false
        # FirstClickThreshold = 1;            # default: 1 - Light=0, Medium=1, Firm=2
        # SecondClickThreshold = 1;           # default: 1
        TrackpadRightClick = true;            # default: false - Two finger right-click
        TrackpadThreeFingerDrag = true;       # default: false - Three finger drag
        # ActuateDetents = true;              # default: true - Haptic feedback
      };

      # Custom Preferences (use for options not exposed by nix-darwin)
      # See: https://daiderd.com/nix-darwin/manual/index.html#opt-system.defaults.CustomUserPreferences
      # CustomUserPreferences = {};

      # Other available defaults namespaces:
      # - system.defaults.screencapture     # Screenshot settings
      # - system.defaults.screensaver       # Screensaver settings
      # - system.defaults.spaces            # Mission Control spaces
      # - system.defaults.universalaccess   # Accessibility settings
      # - system.defaults.ActivityMonitor   # Activity Monitor settings
      # - system.defaults.LaunchServices    # Default apps for file types
      # - system.defaults.loginwindow       # Login window settings
      # - system.defaults.magicmouse        # Magic Mouse settings
      # - system.defaults.menuExtraClock    # Menu bar clock settings
      # - system.defaults.smb               # SMB/file sharing settings
      # - system.defaults.SoftwareUpdate    # Software Update settings
      # - system.defaults.alf               # Firewall settings
    };
  };

  # Machine-specific packages
  environment.systemPackages = [
    # Add machine-specific packages here
  ];
}
