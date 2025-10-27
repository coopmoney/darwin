{ config, pkgs, ... }:

{
  # Home Manager user configuration
  # This file contains user-level packages and dotfiles
  
  # User packages (installed per-user, not system-wide)
  home.packages = with pkgs; [
    # Add user-specific packages here
  ];
  
  # User-level dotfiles can be managed here
  # For now, we're keeping most dotfiles in ~/dotfiles and symlinking them
  # You can gradually migrate more files to home-manager management
  
  home.file = {
    # Example: Manage vim configuration
    # ".vimrc".source = ../vimrc;
    
    # Example: Symlink custom scripts
    # ".local/bin/my-script".source = ../bin/my-script;
  };
  
  # User-level programs can be configured here
  # programs.neovim = {
  #   enable = true;
  #   # ... config ...
  # };
  
  # This value determines the Home Manager release that your
  # configuration is compatible with. Don't change it!
  home.stateVersion = "24.05";
}