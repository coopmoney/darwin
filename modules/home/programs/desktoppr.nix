{ config, pkgs, lib, self, ... }:

{
  programs.desktoppr = {
    enable = true;
    color = "000000";
    picture = "${self}/files/wallpapers/black-hole.png";
  };
}