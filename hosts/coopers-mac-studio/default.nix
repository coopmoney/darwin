# Mac Studio - Darwin system configuration
{ config, pkgs, lib, inputs, hostname, user, ... }:

{
  # Machine-specific network settings
  networking = {
    hostName = "Coopers-Mac-Studio";
    computerName = "Coopers-Mac-Studio";
    localHostName = "Coopers-Mac-Studio";
  };

  # Machine-specific system defaults (uses common defaults, override here if needed)
  # system.defaults = { };

  # Machine-specific packages
  environment.systemPackages = [
    # Add Mac Studio-specific packages here
  ];
}
