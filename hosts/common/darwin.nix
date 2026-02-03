# Common darwin system configuration shared by all hosts
# Individual hosts import this and can extend/override as needed
{ config, pkgs, lib, inputs, hostname, user, hostConfig, ... }:

{
  # Machine-specific network settings derived from hostConfig
  networking = {
    hostName = hostConfig.hostname;
    computerName = hostConfig.computerName;
    localHostName = hostConfig.hostname;
  };

  # Common system defaults
  system.defaults = {
    dock = {
      autohide = true;
      largesize = 64;
      magnification = true;
      minimize-to-application = true;
      mru-spaces = false;
      show-recents = false;
      tilesize = 48;
    };

    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "clmv";
      ShowPathbar = true;
      ShowStatusBar = true;
      _FXSortFoldersFirst = true;
    };

    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleShowAllExtensions = true;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      "com.apple.keyboard.fnState" = true;
      "com.apple.trackpad.scaling" = 3.0;
    };

    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
      TrackpadThreeFingerDrag = true;
    };
  };

  # Common environment packages (hosts can add more)
  environment.systemPackages = [
    # Add common packages here
  ];
}
