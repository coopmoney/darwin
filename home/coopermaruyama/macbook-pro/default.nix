{ config, pkgs, lib, hmModules, ... }:

{
  imports = [
    "${hmModules}/common"
  ];

  # Home Manager basic configuration
  home = {
    username = "coopermaruyama";
    homeDirectory = lib.mkForce "/Users/coopermaruyama";
    stateVersion = "24.05";
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Machine-specific home configuration can go here
}
