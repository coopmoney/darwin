{ config, pkgs, lib, ... }:

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

  # macOS defaults for Raycast
  # These are applied at the system level
  home.activation.raycastDefaults = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # Set Raycast to launch at login
    $DRY_RUN_CMD defaults write com.raycast.macos "NSStatusItem Preferred Position Item-0" -float 0
    
    # Enable/configure Raycast extensions
    $DRY_RUN_CMD defaults write com.raycast.macos showInMenuBar -bool true
    
    # Clipboard history settings
    $DRY_RUN_CMD defaults write com.raycast.macos keepHistoryInClipboard -bool true
    $DRY_RUN_CMD defaults write com.raycast.macos clipboardHistoryLength -int 100
    
    # Window settings
    $DRY_RUN_CMD defaults write com.raycast.macos windowWidth -int 680
    
    # Privacy settings
    $DRY_RUN_CMD defaults write com.raycast.macos navigationCommandStyleIdentifierKey -string "default"
  '';

  # Custom commands and hotkeys can be configured through Raycast UI
  # Export your settings from Raycast and place them in this directory:
  #   - preferences.json: Main Raycast preferences (default included)
  #   - snippets/: Text snippets
  #   - scripts/: Custom scripts
}
