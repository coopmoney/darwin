# System packages
#  helix and custom scripts
{ config, pkgs, lib, inputs, user, ... }:

{
  environment.systemPackages = with pkgs; [
    act
    age
    alacritty
    aws-vault
    awscli2
    bashInteractive
    bat
    betterdisplay
    oxlint
    bun
    chamber
    claude-code
    codex
    coreutils
    curl
    direnv
    discord
    docker
    eza
    fd
    gh
    git
    go
    goose-cli
    htop
    helix
    inputs.flox.packages.${pkgs.system}.default
		inputs.fh.packages.${pkgs.system}.default
    ipmitool
    jq
    kubectl
    lazygit
    lsyncd
    niv
		nixd
    nmap
    nodejs
    # ollama
    postgresql
    ripgrep
    rsync
    spotifyd
    stats
    step-cli
    terraform
    tmux
    tree
    unison
    watch
    wget
		blesh
		flyctl


    # Darwin management script
    (pkgs.writeShellScriptBin "darwin" (builtins.readFile ./scripts/darwin-cli.sh))

    # Backward compatibility aliases
    (pkgs.writeShellScriptBin "osxup" ''
      #!/usr/bin/env bash
      exec darwin apply "$@"
    '')

    (pkgs.writeShellScriptBin "darwinup" ''
      #!/usr/bin/env bash
      exec darwin apply "$@"
    '')

    # Package search utility
    (pkgs.writeShellScriptBin "pkg?" (builtins.readFile ./scripts/pkg-search.sh))
  ];
}

