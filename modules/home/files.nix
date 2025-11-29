# File symlinking configuration
# Source files live in darwin/files/ and get symlinked into ~
{
  config,
  lib,
  self,
  ...
}:

let
  # Flake root directory (like config.git.root in devenv)
  root = self;
  filesDir = "${root}/files";
in
{
  # ~/.config/* symlinks (via XDG)
  xdg.configFile = {
    # Karabiner configuration
    "karabiner".source = "${filesDir}/config/karabiner";

    # 1Password SSH agent config
    "1Password/ssh" = lib.mkIf (builtins.pathExists "${filesDir}/config/1Password") {
      source = "${filesDir}/config/1Password/ssh";
      recursive = true;
    };

    # GitHub CLI config
    "gh" = lib.mkIf (builtins.pathExists "${filesDir}/config/gh") {
      source = "${filesDir}/config/gh";
      recursive = true;
    };
  };

  # ~/* symlinks (home directory)
  home.file = {
    # Zsh functions
    ".zsh/functions" = {
      source = "${filesDir}/zsh/functions";
      recursive = true;
    };

    # Zsh completions
    ".zsh/completion" = {
      source = "${filesDir}/zsh/completion";
      recursive = true;
    };

    # Legacy vim config
    ".vimrc" = lib.mkIf (builtins.pathExists "${filesDir}/dotfiles/vimrc") {
      source = "${filesDir}/dotfiles/vimrc";
    };

    ".vimrc.bundles" = lib.mkIf (builtins.pathExists "${filesDir}/dotfiles/vimrc.bundles") {
      source = "${filesDir}/dotfiles/vimrc.bundles";
    };
  };
}
