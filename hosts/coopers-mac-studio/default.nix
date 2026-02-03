# Mac Studio - Darwin system configuration
{ config, pkgs, lib, inputs, hostname, user, hostConfig, ... }:

{
  imports = [
    # Common darwin base
    ../common/darwin.nix
  ];

  # Machine-specific system defaults (uses common defaults, override here if needed)
  # system.defaults = { };

  # Machine-specific packages
  environment.systemPackages = [
    # Add Mac Studio-specific packages here
  ];
}
