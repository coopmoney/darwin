# Mac Studio - Home Manager configuration
{ config, pkgs, lib, inputs, hostname, user, ... }:

{
  imports = [
    # Common home-manager base
    ../common/home.nix
  ];

  # Machine-specific home configuration
  # Add any Mac Studio-specific settings here
}
