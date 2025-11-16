{ config, lib, ... }:

with lib;

{
  options.wallpapers = {
    enable = mkEnableOption "wallpaper management";

    black-hole = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Black hole wallpaper";
      example = literalExpression "./black-hole.png";
    };

    saturn = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Saturn wallpaper";
      example = literalExpression "./saturn.jpg";
    };

    moon = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Moon wallpaper";
      example = literalExpression "./moon.png";
    };

    moon-lighter = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Moon lighter wallpaper";
      example = literalExpression "./moon-lighter.jpg";
    };

    displays = mkOption {
      type = types.attrsOf types.path;
      default = {
        "Pro Display XDR" = config.wallpapers.black-hole;
        "Color LCD" = config.wallpapers.saturn;
        "DELL AW2518HF" = config.wallpapers.moon;
      };
      description = "Map of display names to wallpaper paths";
      example = literalExpression ''
        {
          "Built-in Retina Display" = ./laptop.jpg;
          "LG UltraWide" = ./ultrawide.jpg;
          "Studio Display" = ./studio.jpg;
        }
      '';
    };
  };

  config = mkIf config.wallpapers.enable {
    home.file."Pictures/wallpaper-black-hole.png" = mkIf (config.wallpapers.black-hole != null) {
      source = config.wallpapers.black-hole;
    };

    home.file."Pictures/wallpaper-saturn.jpg" = mkIf (config.wallpapers.saturn != null) {
      source = config.wallpapers.saturn;
    };

    home.file."Pictures/wallpaper-moon.png" = mkIf (config.wallpapers.moon != null) {
      source = config.wallpapers.moon;
    };

    home.file."Pictures/wallpaper-moon-lighter.jpg" = mkIf (config.wallpapers.moon-lighter != null) {
      source = config.wallpapers.moon-lighter;
    };

    # Copy display-specific wallpapers
    home.file = mkMerge (
      mapAttrsToList (displayName: wallpaperPath: {
        "Pictures/wallpapers/${displayName}.jpg" = {
          source = wallpaperPath;
        };
      }) config.wallpapers.displays
    );

    home.activation.setWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            WALLPAPER_PRIMARY="${config.home.homeDirectory}/Pictures/wallpaper-primary.jpg"
            WALLPAPER_SECONDARY="${config.home.homeDirectory}/Pictures/wallpaper-secondary.jpg"
            WALLPAPERS_DIR="${config.home.homeDirectory}/Pictures/wallpapers"

            # Check if using named displays or numbered displays
            USE_NAMED_DISPLAYS=${if config.wallpapers.displays != { } then "true" else "false"}

            if [ "$USE_NAMED_DISPLAYS" = "true" ]; then
              # Use display names to set wallpapers
              echo "Setting wallpapers by display name..."

              $DRY_RUN_CMD /usr/bin/osascript << 'EOF'
                tell application "System Events"
                  set wallpapersDir to "${config.home.homeDirectory}/Pictures/wallpapers"

                  repeat with aDesktop in desktops
                    -- Get the display name
                    set displayName to name of aDesktop

                    -- Construct wallpaper path
                    set wallpaperPath to wallpapersDir & "/" & displayName & ".jpg"

                    -- Check if wallpaper exists and set it
                    try
                      set picture of aDesktop to wallpaperPath
                      do shell script "echo 'Set wallpaper for display: " & displayName & "'"
                    on error errMsg
                      do shell script "echo 'No wallpaper found for display: " & displayName & "'"
                    end try
                  end repeat
                end tell
      EOF
            else
              # Use numbered displays (legacy mode)
              if [ ! -f "$WALLPAPER_PRIMARY" ] && [ ! -f "$WALLPAPER_SECONDARY" ]; then
                echo "No wallpaper files configured"
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
                        else
                          if (do shell script "test -f '$WALLPAPER_SECONDARY' && echo 'exists' || echo 'missing'") is "exists" then
                            set picture to "$WALLPAPER_SECONDARY"
                          end if
                        end if
                      end tell
                    end repeat
                  end tell
      EOF
                echo "Wallpapers configured"
              fi
            fi
    '';
  };
}
