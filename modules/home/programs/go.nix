# Go development configuration
{ config, pkgs, lib, ... }:

{
  programs.go = {
    enable = true;
    env = {
      GOPATH = "${config.home.homeDirectory}/go";
      GOBIN = "${config.home.homeDirectory}/go/bin";
    };
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/go/bin"
  ];
}

