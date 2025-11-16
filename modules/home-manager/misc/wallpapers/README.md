# Shared Wallpapers

Place your wallpaper images in this directory to share them across all machines.

## Structure

```
wallpapers/
├── default.nix          # Wallpaper module
├── README.md           # This file
├── primary-1.jpg       # Example wallpapers
├── primary-2.jpg
├── secondary-1.jpg
└── secondary-2.jpg
```

## Usage

### Option 1: Named Displays (Recommended)

Target displays by their exact name. To find your display names, run:
```bash
osascript -e 'tell application "System Events" to get name of every desktop'
```

In your machine's home-manager config:

```nix
{ hmModules, ... }:

{
  imports = [
    "${hmModules}/misc/wallpapers"
  ];

  wallpapers = {
    enable = true;
    displays = {
      "Built-in Retina Display" = "${hmModules}/misc/wallpapers/laptop.jpg";
      "LG UltraWide" = "${hmModules}/misc/wallpapers/ultrawide.jpg";
      "Studio Display" = "${hmModules}/misc/wallpapers/studio.jpg";
    };
  };
}
```

### Option 2: Numbered Displays (Legacy)

Use primary/secondary for simple setups:

```nix
wallpapers = {
  enable = true;
  primary = "${hmModules}/misc/wallpapers/primary-1.jpg";
  secondary = "${hmModules}/misc/wallpapers/secondary-1.jpg";
};
```

This will set:
- Display 1 → primary wallpaper
- Display 2+ → secondary wallpaper

## Benefits

- ✅ Keep all wallpapers in one place
- ✅ Share wallpapers across machines
- ✅ Target specific displays by name (won't change if you rearrange displays)
- ✅ Easy per-machine customization
- ✅ Version control your wallpapers with git
