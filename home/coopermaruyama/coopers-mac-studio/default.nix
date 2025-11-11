{ config, pkgs, lib, hmModules, ... }:

{
  # Import common home-manager settings
  imports = [
    "${hmModules}/common"
  ];

  # Home Manager basic configuration
  home = {
    username = "coopermaruyama";
    homeDirectory = lib.mkForce "/Users/coopermaruyama";
    stateVersion = "24.05";
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Machine-specific home configuration
  # You can override any common settings here or add new ones
  
  # Example: Add machine-specific packages
  # home.packages = with pkgs; [
  #   # Add packages here
  # ];
  
  # Example: Override shell aliases
  # programs.zsh.shellAliases = {
  #   # Add or override aliases here
  # };
}
