{
  config,
  pkgs,
  lib,
  hmModules,
  ...
}:

{
  imports = [
    "${hmModules}/common"
  ];

  # Home Manager basic configuration
  home = {
    username = "coopermaruyama";
    homeDirectory = lib.mkForce "/Users/coopermaruyama";
    stateVersion = "24.05";
  };

  # wallpapers = {
  #   enable = true;
  #   displays = {
  #     "Color LCD" = config.wallpapers.black-hole or "${hmModules}/misc/wallpapers/black-hole.png";
  #     "Studio Display" = config.wallpapers.saturn or "${hmModules}/misc/wallpapers/saturn.jpg";
  #   };
  # };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Machine-specific home configuration can go here
}
