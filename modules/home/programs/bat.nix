# Bat (better cat) configuration
{ config, pkgs, lib, ... }:

{
  programs.bat = {
    enable = true;
    config = {
      theme = "catppuccin-mocha";
      style = "numbers,changes,header";
      pager = "less -FR";
    };
  };
}

