{ inputs, darwinModules, ... }:

{
  # Import common Darwin settings
  imports = [
    "${darwinModules}/common"
  ];

  # Machine-specific network settings
  networking.hostName = "Coopers-Mac-Studio";
  networking.computerName = "Coopers-Mac-Studio";
  networking.localHostName = "Coopers-Mac-Studio";

  # System configuration
  system = {
    stateVersion = 1;

    # You can override any defaults here
    # Uncomment and customize as needed:
    
    # defaults = {
    #   dock = {
    #     autohide = true;
    #   };
    #   finder = {
    #     AppleShowAllExtensions = true;
    #   };
    # };
  };

  # Machine-specific packages
  environment.systemPackages = [
    # Add machine-specific packages here
  ];
}
