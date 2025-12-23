# GitHub CLI configuration
{ config, pkgs, lib, ... }:

{
  programs.gh = {
    enable = true;

    # Keep auth tokens out of the Nix store; `gh auth login` stores them in
    # the macOS Keychain.
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };

  # Ensure git uses the macOS Keychain for HTTPS credentials.
  # This plays nicely with `gh auth login` and avoids storing tokens in files.
  programs.git.extraConfig = {
    credential.helper = "osxkeychain";
  };

  # Helper to expose a token to tools that expect $GITHUB_TOKEN.
  # The token is read from the macOS Keychain item:
  #   service: github-token
  #   account: <your GitHub username>
  # Create it once with:
  #   security add-generic-password -a "$USER" -s github-token -w '<TOKEN>'
  home.file.".zsh/functions/github-token".text = ''
    #!/usr/bin/env zsh
    # Print the GitHub token stored in macOS Keychain.
    # Usage:
    #   github-token
    #   export GITHUB_TOKEN=$(github-token)

    set -euo pipefail

    local account
    account="${USER}"

    /usr/bin/security find-generic-password \
      -a "$account" \
      -s github-token \
      -w 2>/dev/null
  '';

  home.file.".zsh/functions/github-token".executable = true;
}
