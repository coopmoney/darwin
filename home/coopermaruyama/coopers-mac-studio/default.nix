{ config, pkgs, lib, hmModules, ... }:

{
  # Import common home-manager settings
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

  # Wallpaper configuration for multiple monitors
  # Place your wallpaper files at:
  #   - home/coopermaruyama/coopers-mac-studio/wallpaper-primary.png
  #   - home/coopermaruyama/coopers-mac-studio/wallpaper-secondary.jpg
  home.file."Pictures/wallpaper-primary.png" = {
    # Uncomment and set the source to your primary display wallpaper
    source = ../../../modules/home-manager/misc/wallpapers/black-hole.png;
  };

  home.file."Pictures/wallpaper-secondary.jpg" = {
    # Uncomment and set the source to your secondary display wallpaper
    source = ../../../modules/home-manager/misc/wallpapers/saturn.jpg;
  };

  # Set wallpapers on activation (supports multiple monitors)
  home.activation.setWallpaper = lib.hm.dag.entryAfter ["writeBoundary"] ''
    WALLPAPER_PRIMARY="${config.home.homeDirectory}/Pictures/wallpaper-primary.png"
    WALLPAPER_SECONDARY="${config.home.homeDirectory}/Pictures/wallpaper-secondary.jpg"
    WALLPAPER_TERTIARY="${config.home.homeDirectory}/Pictures/wallpaper-primary.png"

    # Check if wallpaper files exist
    if [ ! -f "$WALLPAPER_PRIMARY" ] && [ ! -f "$WALLPAPER_SECONDARY" ]; then
      echo "No wallpaper files found."
      echo "To set wallpapers:"
      echo "  1. Place wallpaper files in home/coopermaruyama/coopers-mac-studio/"
      echo "     - wallpaper-primary.jpg (for main display)"
      echo "     - wallpaper-secondary.jpg (for second display)"
      echo "  2. Uncomment the source lines in the config"
      echo "  3. Rebuild with: darwin-rebuild switch"
    else
      # Set wallpapers for each display
      $DRY_RUN_CMD /usr/bin/osascript << EOF
        tell application "System Events"
          set desktopCount to count of desktops

          repeat with desktopNumber from 1 to desktopCount
            tell desktop desktopNumber
              if desktopNumber is 1 then
                if (do shell script "test -f '$WALLPAPER_PRIMARY' && echo 'exists' || echo 'missing'") is "exists" then
                  set picture to "$WALLPAPER_PRIMARY"
                  do shell script "echo 'Display 1: Set to primary wallpaper'"
                end if
              else if desktopNumber is 2 then
                if (do shell script "test -f '$WALLPAPER_SECONDARY' && echo 'exists' || echo 'missing'") is "exists" then
                  set picture to "$WALLPAPER_SECONDARY"
                  do shell script "echo 'Display 2: Set to secondary wallpaper'"
                end if
              else if desktopNumber is 2 then
                if (do shell script "test -f '$WALLPAPER_TERTIARY' && echo 'exists' || echo 'missing'") is "exists" then
                  set picture to "$WALLPAPER_TERTIARY"
                  do shell script "echo 'Display 2: Set to secondary wallpaper'"
                end if
              else
                -- For additional displays, use secondary wallpaper by default
                if (do shell script "test -f '$WALLPAPER_SECONDARY' && echo 'exists' || echo 'missing'") is "exists" then
                  set picture to "$WALLPAPER_SECONDARY"
                  do shell script "echo 'Display " & desktopNumber & ": Set to secondary wallpaper'"
                end if
              end if
            end tell
          end repeat
        end tell
EOF
      echo "Wallpapers configured for all displays"
    fi
  '';

  # Machine-specific home configuration
  # You can override any common settings here or add new ones

  # Example: Add machine-specific packages
  # home.packages = with pkgs; [
  #   # Add packages here
  # ];

  # Example: Override shell aliases
  # programs.zsh.shellAliases = {
  #   # Add or override aliases here
  # };
}
