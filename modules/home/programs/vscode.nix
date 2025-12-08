{ config, pkgs, lib, inputs, ... }:

{
  programs.vscode = {
    enable = false;
    # Use the default stable VS Code package from nixpkgs
    package = pkgs.vscode;

    # Configure the default profile; keep settings minimal and non-invasive
    profiles.default = {
      userSettings = {
        "editor.fontFamily" = "'MonaSpiceNe Nerd Font', monospace";
        "editor.fontLigatures" = true;
        "editor.tabSize" = 2;
        "editor.renderWhitespace" = "boundary";
        "files.trimTrailingWhitespace" = true;
        "files.insertFinalNewline" = true;
        "terminal.integrated.fontFamily" = "MonaSpiceAr Nerd Font";
      };

      # Start with no extensions; user can add later if desired
      extensions = [ ];
      mutableExtensionsDir = true;
    };
  };
}
