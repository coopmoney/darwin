{ config, pkgs, lib, name, fullName, email, gitKey, hmModules, ... }:

{
  # Import all common modules
  imports = [
    "${hmModules}/misc/xdg"
    "${hmModules}/programs/alacritty"
    "${hmModules}/programs/bat"
    "${hmModules}/programs/direnv"
    "${hmModules}/programs/fzf"
    "${hmModules}/programs/git"
    "${hmModules}/programs/go"
    "${hmModules}/programs/lazygit"
    "${hmModules}/programs/starship"
    "${hmModules}/programs/tmux"
    "${hmModules}/programs/zsh"
  ];

  # Basic home configuration
  home = {
    username = name;
    homeDirectory = lib.mkForce "/Users/${name}";

    # User-specific packages
    packages = with pkgs; [
      # Add any user-specific packages here
    ];

    # Session variables
    sessionVariables = {
      EDITOR = "vim";
      VISUAL = "vim";
      PNPM_CACHE_DIR = "${config.home.homeDirectory}/.cache/pnpm";
      XDG_CACHE_HOME = "${config.home.homeDirectory}/.cache";
    };
  };

  # Enable XDG base directories
  xdg.enable = true;

  # Enable Catppuccin theme globally
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "blue";
  };
}
