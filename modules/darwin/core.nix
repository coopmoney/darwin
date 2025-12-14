# Core darwin settings - Nix config, users, security
{
  config,
  pkgs,
  lib,
  inputs,
  user,
  hostname,
  ...
}:

let
  # If we're on the laptop, delegate builds to the studio (host must trust this key)
  builderMachines = lib.optionalString (hostname == "coopers-macbook-pro") ''
    ssh-ng://coopermaruyama@Coopers-Mac-Studio aarch64-darwin /var/root/.ssh/id_ed25519 4 1 big-parallel
  '';
in
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

  # Determinate Nix custom settings via nix.custom.conf
  environment.etc."nix/nix.custom.conf".text = lib.concatStringsSep "\n" ([
    "eval-cores = 0"
    "extra-experimental-features = build-time-fetch-tree parallel-eval"
    "trusted-users = root ${user.username}"
  ]
  ++ lib.optional (builderMachines != "") "builders = @/etc/nix/machines"
  ++ lib.optional (builderMachines != "") "builders-use-substitutes = true"
  ++ [
    # Don't require signed store paths from our own remote builders
    "require-sigs = false"
    ""
  ]);

  # Write the machines file only on hosts that use remote builders
  environment.etc."nix/machines" = lib.mkIf (builderMachines != "") {
    text = builderMachines;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Remove temporary LSP stubs/renames now that nixvim is updated
  nixpkgs.overlays = [ ];

  # Enable zsh system-wide
  programs.zsh.enable = true;
  environment.shells = [ pkgs.zsh ];

  # agenix: Age identities and GitHub PAT secret
  age.identityPaths = [ "${user.homeDirectory}/.config/age/keys.txt" ];
  age.secrets.github_token = {
    file = ../../secrets/github-token.conf.age;
    mode = "0400";
  };

  # Install decrypted token file into nix.conf include path
  environment.etc."nix/github-token.conf".source = config.age.secrets.github_token.path;

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
  ];

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
