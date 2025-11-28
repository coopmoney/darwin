{ config, pkgs, lib, name, fullName, email, gitKey, hmModules, ... }:

{
  # Import all common modules
  imports = [
    "${hmModules}/misc/xdg"
    # UI / programs
    "${hmModules}/programs/alacritty"
    "${hmModules}/programs/bat"
    "${hmModules}/programs/direnv"
    "${hmModules}/programs/fzf"
    "${hmModules}/programs/git"
    "${hmModules}/programs/go"
    "${hmModules}/programs/karabiner"
    "${hmModules}/programs/lazygit"
    "${hmModules}/programs/raycast"
    "${hmModules}/programs/starship"
    "${hmModules}/programs/tmux"
    "${hmModules}/programs/zsh"

    # New modules
    "${hmModules}/programs/nvim"
    "${hmModules}/programs/llm"
    "${hmModules}/misc/theme/apathy"
  ];

  # Basic home configuration
  home = {
    username = name;
    homeDirectory = lib.mkForce "/Users/${name}";

    # User-specific packages
    packages = with pkgs; [
      # Add any user-specific packages here
      devenv
      goose-cli
    ];

    # Session variables
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
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
