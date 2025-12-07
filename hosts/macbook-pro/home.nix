# MacBook Pro - Home Manager configuration
{ config, pkgs, lib, inputs, hostname, user, ... }:

{
  imports = [
    # Common home-manager modules
    ../../modules/home
  ];

  # Home Manager basic configuration
  home = {
    username = user.username;
    homeDirectory = lib.mkForce user.homeDirectory;
    stateVersion = "24.05";
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Machine-specific home configuration
  # Add any MacBook Pro-specific settings here
}

