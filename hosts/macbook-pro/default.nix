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
      # Dock
      dock = {
        autohide = true;
        mru-spaces = false;
        minimize-to-application = true;
        show-recents = false;
      };

      # Finder
      finder = {
        AppleShowAllExtensions = true;
        FXEnableExtensionChangeWarning = false;
        ShowPathbar = true;
        ShowStatusBar = true;
      };

      # Global
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        AppleShowAllExtensions = true;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
      };
    };
  };

  # Machine-specific packages
  environment.systemPackages = [
    # Add machine-specific packages here
  ];
}
