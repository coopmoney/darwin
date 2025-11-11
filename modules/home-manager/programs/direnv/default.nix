{ config, lib, ... }:

{
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;

    config = {
      global = {
        load_dotenv = true;
        strict_env = false;
        warn_timeout = "30s";
      };

      whitelist = {
        prefix = [
          "${config.home.homeDirectory}/Developer"
          "${config.home.homeDirectory}/Projects"
        ];
      };
    };

    stdlib = ''
      # Custom direnv functions

      # Layout for Python projects
      layout_python() {
        if [[ -f pyproject.toml ]]; then
          if has poetry; then
            layout_poetry
          elif has pipenv; then
            layout_pipenv
          else
            layout_python3
          fi
        else
          layout_python3
        fi
      }

      # Layout for Node projects
      layout_node() {
        PATH_add node_modules/.bin
        if [[ -f .nvmrc ]]; then
          use node
        fi
      }

      # AWS profile helper
      use_aws_profile() {
        export AWS_PROFILE=$1
      }
    '';
  };

  # Global gitignore for direnv
  home.file.".gitignore_global".text = lib.mkAfter ''
    # Direnv
    .direnv/
    .envrc
  '';
}
