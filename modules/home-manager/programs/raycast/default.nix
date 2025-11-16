{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Raycast configuration
  # Note: Raycast must be installed via Homebrew or manually
  # This module manages preferences and settings

  # Raycast preferences - includes sensible defaults
  home.file.".config/raycast/preferences.json" = {
    source = ./preferences.json;
  };

  # Raycast snippets
  home.file.".config/raycast/snippets" = lib.mkIf (builtins.pathExists ./snippets) {
    source = ./snippets;
    recursive = true;
  };

  # Raycast scripts
  home.file.".config/raycast/scripts" = lib.mkIf (builtins.pathExists ./scripts) {
    source = ./scripts;
    recursive = true;
  };

  # Custom commands and hotkeys can be configured through Raycast UI
  # Export your settings from Raycast and place them in this directory:
  #   - preferences.json: Main Raycast preferences (default included)
  #   - snippets/: Text snippets
  #   - scripts/: Custom scripts
}
