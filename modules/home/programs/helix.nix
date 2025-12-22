{ config, pkgs, lib, ... }:

{
  programs.helix = {
    enable = true;

    settings = {
      theme = "tokyonight_storm";
      editor = {
        true-color = true;
        line-number = "relative";
        cursorline = true;
        bufferline = "multiple";
        rulers = [ 80 120 ];
      };
    };
  };

  xdg.configFile."helix/themes/tokyonight_storm.toml".text = ''
    "inherits" = "tokyonight"

    "ui.background" = { bg = "bg" }

    [palette]
    bg = "#1f2335"
  '';
}
