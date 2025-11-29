# Raycast configuration
{ config, pkgs, lib, ... }:

{
  # Raycast is installed via Homebrew
  # This module manages preferences and settings
  home.file.".config/raycast/preferences.json".source =
    ../../home-manager/programs/raycast/preferences.json;
}

