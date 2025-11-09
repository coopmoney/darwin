{ config, lib, ... }:

{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_status"
        "$c"
        "$elixir"
        "$elm"
        "$golang"
        "$haskell"
        "$java"
        "$julia"
        "$nodejs"
        "$nim"
        "$rust"
        "$scala"
        "$docker_context"
        "$aws"
        "$env_var"
        "$cmd_duration"
        "$line_break"
        "$jobs"
        "$battery"
        "$time"
        "$status"
        "$shell"
        "$character"
      ];

      username = {
        show_always = false;
        style_user = "bg:blue fg:black";
        style_root = "bg:blue fg:red bold";
        format = "[$user]($style)";
      };

      hostname = {
        ssh_only = true;
        format = "[@$hostname]($style) ";
        style = "bold green";
      };

      directory = {
        style = "cyan bold";
        repo_root_style = "cyan bold underline";
        format = "[$path]($style)[$read_only]($read_only_style) ";
        truncation_length = 3;
        truncate_to_repo = true;
      };

      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };

      git_branch = {
        symbol = " ";
        style = "bold purple";
        format = "[$symbol$branch]($style) ";
      };

      git_status = {
        format = "([$all_status$ahead_behind]($style) )";
        style = "bold red";
        conflicted = "🏳";
        up_to_date = "";
        untracked = "🤷";
        stashed = "📦";
        modified = "📝";
        staged = "[++\($count\)](green)";
        renamed = "👅";
        deleted = "🗑";
      };

      nodejs = {
        symbol = " ";
        style = "bold green";
        format = "[$symbol($version )]($style)";
      };

      golang = {
        symbol = " ";
        style = "bold cyan";
        format = "[$symbol($version )]($style)";
      };

      python = {
        symbol = " ";
        style = "yellow bold";
        format = "[$symbol($pyenv_prefix)($version )(\($virtualenv\) )]($style)";
      };

      rust = {
        symbol = " ";
        style = "bold red";
        format = "[$symbol($version )]($style)";
      };

      docker_context = {
        symbol = " ";
        style = "blue bold";
        format = "[$symbol$context]($style) ";
        only_with_files = true;
      };

      aws = {
        symbol = "  ";
        style = "bold orange";
        format = "[$symbol($profile )(\\($region\\) )]($style)";
        disabled = false;
      };

      cmd_duration = {
        min_time = 2000;
        format = "⏱ [$duration](bold yellow)";
      };

      line_break = {
        disabled = false;
      };

      battery = {
        full_symbol = "🔋 ";
        charging_symbol = "⚡️ ";
        discharging_symbol = "💀 ";
        display = [
          {
            threshold = 10;
            style = "bold red";
          }
          {
            threshold = 30;
            style = "bold yellow";
          }
        ];
      };

      time = {
        disabled = true;
        format = "🕙[\\[ $time \\]]($style) ";
        time_format = "%T";
      };
    };
  };

  # Disable p10k if starship is enabled
  programs.zsh.initContent = lib.mkBefore ''
    # Disable p10k when using starship
    if command -v starship &> /dev/null; then
      export POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
    fi
  '';
}
