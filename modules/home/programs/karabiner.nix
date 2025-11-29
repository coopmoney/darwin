# Karabiner-Elements configuration
{ config, pkgs, lib, ... }:

{
  # Karabiner-Elements is installed via Homebrew
  # This module manages the configuration file
  home.file.".config/karabiner/karabiner.json".source =
    ../../home-manager/programs/karabiner/karabiner.json;
}

