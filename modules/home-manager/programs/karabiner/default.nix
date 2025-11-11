{ config, pkgs, lib, ... }:

{
  # Karabiner-Elements configuration
  # Note: Karabiner-Elements must be installed via nix-darwin or manually
  # This module manages the configuration file

  home.file.".config/karabiner/karabiner.json".source = ./karabiner.json;
}
