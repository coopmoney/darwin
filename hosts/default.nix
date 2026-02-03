# Host definitions - centralized configuration for all machines
# Each host defines its system type, user, and naming conventions
{
  coopers-mac-studio = {
    system = "aarch64-darwin";
    user = "coopermaruyama";
    # The hostname (used for darwinConfigurations key, network hostname, and .local name)
    hostname = "Coopers-Mac-Studio";
    # Human-friendly name shown in Finder/AirDrop (can have spaces/apostrophes)
    computerName = "Coopers-Mac-Studio";
  };

  macbook-pro = {
    system = "aarch64-darwin";
    user = "coopermaruyama";
    hostname = "Coopers-MacBook-Pro";
    computerName = "Cooper's MacBook Pro";
  };

  macpro = {
    system = "aarch64-darwin";
    user = "cm";
    hostname = "Coopers-Mac-Pro";
    computerName = "Coopers-Mac-Pro";
  };
}
