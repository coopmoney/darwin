{ config, pkgs, ... }:

{
  programs.bat = {
    enable = true;

    config = {
      pager = "less -FR";
      map-syntax = [
        "*.jenkinsfile:Groovy"
        "*.props:Java Properties"
      ];
    };

    extraPackages = with pkgs.bat-extras; [
      batdiff
      batman
      batgrep
      batwatch
    ];
  };

  # Set bat as MANPAGER
  home.sessionVariables = {
    MANPAGER = "sh -c 'col -bx | ${pkgs.bat}/bin/bat -l man -p'";
  };

  # Shell aliases for bat
  home.shellAliases = {
    cat = "bat";
    catp = "bat -p"; # Plain output, no line numbers
  };
}
