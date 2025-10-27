{ ... }:

{
  # macOS system defaults migrated from ~/dotfiles/macos script
  # These settings are applied declaratively by nix-darwin
  
  system.defaults = {
    # Dock settings
    dock = {
      autohide = false;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.0;
      tilesize = 36;
      minimize-to-application = true;
      show-process-indicators = true;
      launchanim = false;
      expose-animation-duration = 0.1;
      expose-group-by-app = false;
      mru-spaces = false;
      mineffect = "scale";
      enable-spring-load-actions-on-all-items = true;
      mouse-over-hilite-stack = true;
      dashboard-in-overlay = true;
    };
    
    # Finder settings
    finder = {
      AppleShowAllExtensions = true;
      ShowStatusBar = true;
      ShowPathbar = true;
      FXDefaultSearchScope = "SCcf";  # Search current folder by default
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "Nlsv";  # List view
      _FXShowPosixPathInTitle = true;
      _FXSortFoldersFirst = true;
      QuitMenuItem = true;
      
      # Show drives on desktop
      ShowExternalHardDrivesOnDesktop = true;
      ShowHardDrivesOnDesktop = true;
      ShowMountedServersOnDesktop = true;
      ShowRemovableMediaOnDesktop = true;
    };
    
    # Global macOS settings
    NSGlobalDomain = {
      # Keyboard
      ApplePressAndHoldEnabled = false;  # Disable press-and-hold for key repeat
      KeyRepeat = 2;
      InitialKeyRepeat = 25;
      AppleKeyboardUIMode = 3;  # Full keyboard access
      
      # Typing assistance (disable for coding)
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      
      # Trackpad
      "com.apple.mouse.tapBehavior" = 1;  # Tap to click
      "com.apple.swipescrolldirection" = false;  # Disable natural scrolling
      
      # UI
      AppleShowAllExtensions = true;
      NSUseAnimatedFocusRing = false;
      NSWindowResizeTime = 0.001;
      NSToolbarTitleViewRolloverDelay = 0.0;
      
      # Save/print panels
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
      PMPrintingExpandedStateForPrint = true;
      PMPrintingExpandedStateForPrint2 = true;
      
      # Misc
      NSDisableAutomaticTermination = false;
      AppleFontSmoothing = 1;
      "com.apple.springing.enabled" = true;
      "com.apple.springing.delay" = 0.0;
    };
    
    # Screen capture settings
    screencapture = {
      location = "~/Desktop";
      type = "png";
      disable-shadow = false;
    };
    
    # Trackpad
    trackpad = {
      Clicking = true;  # Tap to click
      TrackpadRightClick = true;
    };
    
    # Login window
    loginwindow = {
      GuestEnabled = false;
    };
    
    # Menu extras (icons in menu bar)
    # CustomUserPreferences = {
    #   "com.apple.controlcenter" = {
    #     BatteryShowPercentage = true;
    #   };
    # };
  };
  
  # Activation scripts for settings not covered by system.defaults
  system.activationScripts.postActivation.text = ''
    echo "Setting additional macOS defaults..."
    
    # Disable the sound effects on boot
    sudo nvram SystemAudioVolume=" " 2>/dev/null || true
    
    # Avoid creating .DS_Store files on network or USB volumes
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
    
    # Show the ~/Library folder
    chflags nohidden ~/Library 2>/dev/null || true
    
    # Disable disk image verification
    defaults write com.apple.frameworks.diskimages skip-verify -bool true
    defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
    defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true
    
    # Auto-open new Finder window when volume is mounted
    defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
    defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
    defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true
    
    # Disable Dashboard
    defaults write com.apple.dashboard mcx-disabled -bool true
    
    # Show IP address in login window
    sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName 2>/dev/null || true
    
    # Enable HiDPI display modes
    sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true 2>/dev/null || true
    
    echo "macOS defaults configured successfully!"
  '';
}