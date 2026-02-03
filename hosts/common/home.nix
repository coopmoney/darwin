# Common home-manager configuration shared by all hosts
# Individual hosts import this and can extend/override as needed
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

  # Wallpaper configuration for multiple monitors
  home.file."Pictures/wallpaper-primary.png".source = ./wallpapers/primary.png;
  home.file."Pictures/wallpaper-secondary.jpg".source = ./wallpapers/secondary.jpg;
  home.file."Pictures/wallpaper-tertiary.jpg".source = ./wallpapers/tertiary.jpg;

  # Set wallpapers on activation
  home.activation.setWallpaper = lib.hm.dag.entryAfter ["writeBoundary"] ''
    WALLPAPER_PRIMARY="${config.home.homeDirectory}/Pictures/wallpaper-primary.png"
    WALLPAPER_SECONDARY="${config.home.homeDirectory}/Pictures/wallpaper-secondary.jpg"
    WALLPAPER_TERTIARY="${config.home.homeDirectory}/Pictures/wallpaper-tertiary.jpg"

    if [ ! -f "$WALLPAPER_PRIMARY" ] && [ ! -f "$WALLPAPER_SECONDARY" ] && [ ! -f "$WALLPAPER_TERTIARY" ]; then
      echo "No wallpaper files found."
    else
      $DRY_RUN_CMD /usr/bin/osascript << EOF
        tell application "System Events"
          set desktopCount to count of desktops
          repeat with desktopNumber from 1 to desktopCount
            tell desktop desktopNumber
              if desktopNumber is 1 then
                if (do shell script "test -f '$WALLPAPER_PRIMARY' && echo 'exists' || echo 'missing'") is "exists" then
                  set picture to "$WALLPAPER_PRIMARY"
                end if
              else if desktopNumber is 2 then
                if (do shell script "test -f '$WALLPAPER_SECONDARY' && echo 'exists' || echo 'missing'") is "exists" then
                  set picture to "$WALLPAPER_SECONDARY"
                end if
              else if desktopNumber is 3 then
                if (do shell script "test -f '$WALLPAPER_TERTIARY' && echo 'exists' || echo 'missing'") is "exists" then
                  set picture to "$WALLPAPER_TERTIARY"
                end if
              end if
            end tell
          end repeat
        end tell
EOF
      echo "Wallpapers configured for all displays"
    fi
  '';
}
