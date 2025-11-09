{ config, pkgs, ... }:

{
  programs.go = {
    enable = true;
    env = {
      GOPATH = "${config.home.homeDirectory}/.go";
      GOBIN = "${config.home.homeDirectory}/.go/bin";
    };
  };

  home.packages = with pkgs; [
    # Go tools
    gopls
    go-tools
    golangci-lint
    delve
    gomodifytags
    gotests
    impl
  ];

  home.sessionPath = [
    "${config.home.homeDirectory}/.go/bin"
  ];

  home.sessionVariables = {
    GO111MODULE = "on";
    GOPATH = "${config.home.homeDirectory}/.go";
  };
}
