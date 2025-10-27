{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "coopermaruyama";
  home.homeDirectory = "/Users/coopermaruyama";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes to see if there have been any backwards incompatible changes
  # made to the relevant options.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content inline.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';

    # Create .cache directory with pnpm subdirectory
    ".cache".source = pkgs.runCommand "cache-dir" { } ''
      mkdir -p $out/pnpm
      # Set permissions to allow read/write for the user
      chmod 755 $out
      chmod 755 $out/pnpm
    '';
  };

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
}
