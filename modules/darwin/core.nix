# Core darwin settings - Nix config, users, security
{
  config,
  pkgs,
  lib,
  inputs,
  user,
  ...
}:

{
  # Required for nix-darwin
  system.stateVersion = 1;

  # Primary user configuration
  system.primaryUser = user.username;
  users.users.${user.username} = {
    name = user.username;
    home = user.homeDirectory;
  };

  # Nix configuration (let Determinate handle most of it)
  nix.enable = false;

  # Determinate Nix settings
  determinate-nix.customSettings = {
    eval-cores = 0;
    extra-experimental-features = [
      "build-time-fetch-tree"
      "parallel-eval"
    ];
    trusted-users = [
      "root"
      user.username
    ];
    # Remote builders
    builders = "ssh://coopermaruyama@coopers-mac-studio ; ssh://cooper@coopers-mac-pro ; ssh://admin@65.108.233.35";
    builders-use-substitutes = true;
    # Don't require signed store paths from our own remote builders
    require-sigs = false;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable zsh system-wide
  programs.zsh.enable = true;
  environment.shells = [ pkgs.zsh ];

  # Environment variables
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    STARSHIP_CONFIG = "${user.homeDirectory}/darwin/files/starship.toml";
  };

  # System keyboard remapping
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };

  # Touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  security.sudo.extraConfig = lib.concatStringsSep "\n" [
    "${user.username} ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/darwin-rebuild"
  ]
  ;

  # User-level launchd agent for Ollama
  # TEMPORARILY DISABLED: Ollama 0.13.0 has build failures on macOS
  # See: https://github.com/NixOS/nixpkgs/issues/345333
  # launchd.user.agents."dev.ollama.user" = {
  #   serviceConfig = {
  #     ProgramArguments = [
  #       "${pkgs.ollama}/bin/ollama"
  #       "serve"
  #     ];
  #     RunAtLoad = true;
  #     KeepAlive = true;
  #     EnvironmentVariables = {
  #       OLLAMA_HOST = "127.0.0.1:11434";
  #       OLLAMA_MODELS = "${user.homeDirectory}/.local/share/ollama/models";
  #     };
  #     StandardOutPath = "${user.homeDirectory}/.local/state/ollama/ollama.out.log";
  #     StandardErrorPath = "${user.homeDirectory}/.local/state/ollama/ollama.err.log";
  #   };
  # };
}
