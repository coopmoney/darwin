# Starship prompt configuration - matching lualine theme
{ lib, ... }:

{
  # Disable catppuccin's starship integration since we use a custom palette
  catppuccin.starship.enable = false;

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
			format = lib.concatStrings [
				"[░▒▓](fg:surface2)"
				"[ $os](bg:gray fg:white)"
				"[](bg:black fg:gray)"
				"$directory"
				"[](bg:white fg:black)"
				"$git_branch"
				"[](fg:white)"
				"[ $git_status[](fg:base)](bg:base)"
				"$fill"
				"$aws"
				"$nix_shell"
        "$username"
				"$time"
				"$line_break"
				"$shlvl"
				"$character"
			];

      palette = "apathy";

      fill = {
        disabled = false;
        symbol = " ";
      };

      os = {
        disabled = false;
        style = "bg:gray fg:white";
        symbols = {
          Windows = "";
          Ubuntu = "󰕈";
          SUSE = "";
          Raspbian = "󰐿";
          Mint = "󰣭";
          Macos = "󰀵";
          Manjaro = "";
          Linux = "󰌽";
          Gentoo = "󰣨";
          Fedora = "󰣛";
          Alpine = "";
          Amazon = "";
          Android = "";
          AOSC = "";
          Arch = "󰣇";
          Artix = "󰣇";
          CentOS = "";
          Debian = "󰣚";
          Redhat = "󱄛";
          RedHatEnterprise = "󱄛";
        };
      };

      username = {
        show_always = true;
        style_user = "fg:white bg:gray";
        style_root = "fg:red bg:gray";
        format = "[ $user ]($style)";
      };

      directory = {
        style = "bg:black fg:white";
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncation_symbol = "…/";
        substitutions = {
          "Documents" = "󰈙 ";
          "Downloads" = " ";
          "Music" = "󰝚 ";
          "Pictures" = " ";
          "Developer" = "󰲋 ";
        };
      };

      git_branch = {
        symbol = "";
        style = "bg:white fg:black";
        format = "[ $symbol $branch ]($style)";
      };

      git_status = {
        style = "bold bg:base fg:sky";
        format = "[$all_status]($style)";
      };

      git_metrics = {
        disabled = true;
        added_style = "bg:base fg:green";
        deleted_style = "bg:base fg:red";
        format = "[+$added]($added_style) [-$deleted]($deleted_style) ";
      };

      nodejs = {
        symbol = "";
        style = "bg:green";
        format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
      };

      nix_shell = {
        disabled = false;
        impure_msg = "[impure](maroon)";
        pure_msg = "[pure](sky)";
        unknown_msg = "[unknown](mauve)";
        format = "[ $state( $name)](overlay0) ";
      };

      shlvl = {
        disabled = false;
        format = "[$symbol]($style)";
        repeat = true;
        symbol = "❯";
        repeat_offset = 1;
      };

      shell = {
        fish_indicator = "󰈺 ";
        powershell_indicator = "_";
        unknown_indicator = "mystery shell";
        style = "cyan bold";
        disabled = true;
      };

      aws = {
        symbol = "";
        style = "fg:yellow";
        format = "[[ $symbol( $version) ](fg:crust)]($style)";
      };

      time = {
        disabled = false;
        time_format = "%R";
        style = "fg:subtext0";
        format = "[  $time ]($style)";
      };

      battery = {
        format = "[$symbol$percentage]($style) ";
        disabled = false;
      };

      line_break = {
        disabled = false;
      };

      character = {
        disabled = false;
        success_symbol = "[❯](bold fg:green)";
        error_symbol = "[❯](bold fg:red)";
        vimcmd_symbol = "[❮](bold fg:green)";
        vimcmd_replace_one_symbol = "[❮](bold fg:lavender)";
        vimcmd_replace_symbol = "[❮](bold fg:lavender)";
        vimcmd_visual_symbol = "[❮](bold fg:yellow)";
      };

      cmd_duration = {
        show_milliseconds = true;
        format = " in $duration ";
        style = "bg:lavender";
        disabled = false;
        show_notifications = true;
        min_time_to_notify = 45000;
      };

      palettes.apathy = {
        gray = "#575B60";
        black = "#16181D";
        white = "#D7D8E0";
        rosewater = "#f0c9dd";
        flamingo = "#f0c9dd";
        pink = "#f5c2e7";
        mauve = "#998fe1";
        red = "#bb4561";
        maroon = "#eba0ac";
        peach = "#fab387";
        yellow = "#ffcb6b";
        green = "#a6e3a1";
        teal = "#93e3db";
        sky = "#baf8e5";
        sapphire = "#33b3cc";
        blue = "#89b4fa";
        lavender = "#b4befe";
        text = "#cdd6f4";
        subtext1 = "#bac2de";
        subtext0 = "#a6adc8";
        overlay2 = "#9399b2";
        overlay1 = "#7f849c";
        overlay0 = "#6c7086";
        surface2 = "#585b70";
        surface1 = "#45475a";
        surface0 = "#313244";
        base = "#1e1e2e";
        mantle = "#181825";
        crust = "#11111b";
      };
    };
  };

  programs.zsh.initContent = lib.mkBefore ''
    if command -v starship &> /dev/null; then
      export POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
    fi
  '';
}
