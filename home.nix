{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Home Manager user configuration
  # This file contains user-level packages and dotfiles

  # Explicitly set the user and home directory for nix-darwin integration
  home.username = "coopermaruyama";
  home.homeDirectory = lib.mkForce "/Users/coopermaruyama";

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
    # ".zshrc".source = ./zsh/zshrc;
  };

  # User-level programs can be configured here
  # programs.neovim = {
  #   enable = true;
  #   # ... config ...
  # };

  # You can also manage environment variables but you will have to manually
  # source the file.
  home.sessionVariables = {
    # Configure pnpm to use the .cache directory
    PNPM_CACHE_DIR = "${config.home.homeDirectory}/.cache/pnpm";
    # Alternative: you can also use XDG_CACHE_HOME which pnpm respects
    XDG_CACHE_HOME = "${config.home.homeDirectory}/.cache";
    HELLO = "world";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # This value determines the Home Manager release that your
  # configuration is compatible with. Don't change it!
  home.stateVersion = "24.05";
}
