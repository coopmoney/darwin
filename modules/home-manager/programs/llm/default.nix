{ config, pkgs, lib, ... }:

let
  envDir = "${config.xdg.configHome}/secrets";
  envFile = "${envDir}/llm.env";

  loader = pkgs.writeShellScriptBin "op-llm-env" ''
    #!/usr/bin/env bash
    set -euo pipefail

    dest="''${XDG_CONFIG_HOME:-$HOME/.config}/secrets/llm.env"
    umask 077
    mkdir -p "$(dirname "$dest")"

    if ! command -v op >/dev/null 2>&1; then
      echo "1Password CLI (op) not found." >&2
      exit 1
    fi

    # Ensure signed in (requires prior `op signin` in your shell or the GUI agent)
    if ! op account list >/dev/null 2>&1; then
      echo "You must sign in to 1Password first: op signin" >&2
      exit 1
    fi

    # Read secrets (as provided)
    openai=$(op read op://services/neovim/openai-api-key --account my)
    anthropic=$(op read op://services/neovim/anthropic-api-key --account my)

    # Write minimal env file
    cat >"$dest" <<EOF
export OPENAI_API_KEY="''${openai}"
export ANTHROPIC_API_KEY="''${anthropic}"
# Default endpoints (override if needed)
export OPENAI_API_BASE="https://api.openai.com/v1"
export ANTHROPIC_API_BASE="https://api.anthropic.com"
# Ollama defaults to local
export OLLAMA_HOST="http://127.0.0.1:11434"
EOF

    chmod 600 "$dest"
    echo "Wrote $dest"
  '';

in {
  home.packages = [ pkgs._1password-cli loader ];

  # Source the env automatically for new shells if present
  xdg.configFile."zsh/profile.d/llm-env.zsh".text = ''
    if [ -f "${envFile}" ]; then
      source "${envFile}"
    fi
  '';
}
