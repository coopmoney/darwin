{ config, pkgs, lib, ... }:

let
  label = "dev.ollama.user";
in
{
  home.packages = [ pkgs.ollama ];

  launchd.user.agents.${label} = {
    enable = true;
    config = {
      ProgramArguments = [ "${pkgs.ollama}/bin/ollama" "serve" ];
      RunAtLoad = true;
      KeepAlive = true;
      EnvironmentVariables = {
        OLLAMA_HOST = "127.0.0.1:11434";
        OLLAMA_MODELS = "${config.xdg.dataHome}/ollama/models";
      };
      StandardOutPath = "${config.xdg.stateHome}/ollama/ollama.out.log";
      StandardErrorPath = "${config.xdg.stateHome}/ollama/ollama.err.log";
    };
  };
}
