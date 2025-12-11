# File symlinking configuration
# Source files live in darwin/files/ and get symlinked into ~
{
  config,
  lib,
  self,
  ...
}:

let
  homeDir = config.home.homeDirectory;
  filesDir = "${homeDir}/darwin/files";

  # List of writable symlinks: { target = "~/.config/foo"; source = "~/darwin/files/..."; }
  writableSymlinks = [
    { target = ".config/zed"; source = "${filesDir}/config/zed"; }
    { target = ".config/karabiner"; source = "${filesDir}/config/karabiner"; }
    { target = ".config/raycast"; source = "${filesDir}/config/raycast"; }
    { target = "darkmatter/darkmatter.code-workspace"; source = "${filesDir}/vscode/darkmatter.code-workspace"; }
    { target = ".warp/themes/standard/apathy.yaml"; source = "${filesDir}/warp/apathy.yaml"; }
  ];

  # Generate shell commands to create direct symlinks
  mkSymlinkCmd = { target, source }: ''
    target="${homeDir}/${target}"
    source="${source}"
    if [ -e "$source" ]; then
      mkdir -p "$(dirname "$target")"
      # Remove existing file/symlink/directory if it points elsewhere
      if [ -L "$target" ]; then
        current=$(readlink "$target")
        if [ "$current" != "$source" ]; then
          rm "$target"
          ln -s "$source" "$target"
          echo "Updated symlink: $target -> $source"
        fi
      elif [ -e "$target" ]; then
        echo "Warning: $target exists and is not a symlink, skipping"
      else
        ln -s "$source" "$target"
        echo "Created symlink: $target -> $source"
      fi
    fi
  '';
in
{
  # ============================================
  # READ-ONLY FILES (symlinked via Nix store)
  # ============================================

  xdg.configFile = {
    "1Password/ssh" = lib.mkIf (builtins.pathExists "${self}/files/config/1Password") {
      source = "${self}/files/config/1Password/ssh";
      recursive = true;
    };

    "gh" = lib.mkIf (builtins.pathExists "${self}/files/config/gh") {
      source = "${self}/files/config/gh";
      recursive = true;
    };
  };

  home.file = {
    ".zsh/functions" = {
      source = "${self}/files/zsh/functions";
      recursive = true;
    };

    ".zsh/completion" = {
      source = "${self}/files/zsh/completion";
      recursive = true;
    };

    ".vimrc" = lib.mkIf (builtins.pathExists "${self}/files/vimrc") {
      source = "${self}/files/vimrc";
    };

    ".vimrc.bundles" = lib.mkIf (builtins.pathExists "${self}/files/vimrc.bundles") {
      source = "${self}/files/vimrc.bundles";
    };
  };

  # ============================================
  # WRITABLE FILES (direct symlinks via activation)
  # ============================================
  # These create direct symlinks: ~/.config/foo -> ~/darwin/files/config/foo
  # No Nix store in the path = editors see them as writable

  home.activation.createWritableSymlinks = lib.hm.dag.entryAfter ["writeBoundary"] ''
    echo "Creating direct symlinks for writable configs..."
    ${lib.concatMapStrings mkSymlinkCmd writableSymlinks}
  '';
}
