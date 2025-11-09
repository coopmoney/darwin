{ config, pkgs, lib, ... }:

{
  programs.alacritty = {
    enable = true;

    settings = {
      # Window configuration
      window = {
        padding = {
          x = 10;
          y = 10;
        };
        decorations = "buttonless";
        opacity = 0.95;
        dynamic_title = true;
      };

      # Font configuration
      font = {
        size = 14.0;
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "JetBrainsMono Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "JetBrainsMono Nerd Font";
          style = "Italic";
        };
        bold_italic = {
          family = "JetBrainsMono Nerd Font";
          style = "Bold Italic";
        };
      };

      # Cursor configuration
      cursor = {
        style = {
          shape = "Block";
          blinking = "Off";
        };
      };

      # Shell configuration
      shell = {
        program = "${pkgs.zsh}/bin/zsh";
        args = [ "-l" ];
      };

      # Key bindings
      keyboard.bindings = [
        # macOS specific bindings
        { key = "K"; mods = "Command"; action = "ClearHistory"; }
        { key = "V"; mods = "Command"; action = "Paste"; }
        { key = "C"; mods = "Command"; action = "Copy"; }
        { key = "Q"; mods = "Command"; action = "Quit"; }
        { key = "W"; mods = "Command"; action = "Quit"; }
        { key = "N"; mods = "Command"; action = "SpawnNewInstance"; }
        { key = "F"; mods = "Command|Control"; action = "ToggleFullscreen"; }
        { key = "Plus"; mods = "Command"; action = "IncreaseFontSize"; }
        { key = "Minus"; mods = "Command"; action = "DecreaseFontSize"; }
        { key = "Key0"; mods = "Command"; action = "ResetFontSize"; }
      ];

      # Scrolling
      scrolling = {
        history = 10000;
        multiplier = 3;
      };

      # Selection
      selection = {
        save_to_clipboard = true;
        semantic_escape_chars = ",│`|:\"' ()[]{}<>\t";
      };

      # Mouse
      mouse = {
        hide_when_typing = true;
      };
    };
  };
}
