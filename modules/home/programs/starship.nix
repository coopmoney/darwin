# Starship prompt configuration - matching lualine theme
{ lib, ... }:

{
  # Disable catppuccin's starship integration since we use a custom palette
  catppuccin.starship.enable = false;

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      format = ''
        [░▒▓](fg:surface2)\
        [  ](bg:gray fg:white)\
        [](bg:black fg:gray)\
        $username\
        [](bg:white fg:black)\
        $directory\
        [](fg:white)\
        $fill\
        $line_break\
        $character\
      '';

      right_format = ''
        $nix_shell\
        $aws\
        $git_branch\
        $git_status\
        [](bg:black fg:gray)\
        $time\
      '';

      palette = "apathy";

      os = {
        disabled = false;
        style = "bg:red fg:crust";
      };

      "os.symbols" = {
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

      username = {
        show_always = true;
        style_user = "bg:black fg:subtext0";
        style_root = "bg:black fg:red";
        format = "[ $user ]($style)";
      };

      directory = {
        style = "bg:white fg:black";
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
        style = "bg:black";
        format = "[[ $symbol $branch ](fg:sky bg:black)]($style)";
      };

      git_status = {
        style = "bg:yellow";
        format = "[[($all_status$ahead_behind )](fg:crust bg:yellow)]($style)";
      };

      nodejs = {
        symbol = "";
        style = "bg:green";
        format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
      };

      nix_shell = {
        disabled = true;
        impure_msg = "[impure shell](bold mauve)";
        pure_msg = "[pure shell](bold sky)";
        unknown_msg = "[unknown shell](bold yellow)";
        format = "via [☃️ $state( \\($name\\))](bold blue) ";
      };

      shlvl = {
        disabled = false;
        format = "$shlvl level(s) down";
        threshold = 3;
      };

      c = {
        symbol = " ";
        style = "bg:green";
        format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
      };

      rust = {
        symbol = "";
        style = "bg:green";
        format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
      };

      golang = {
        symbol = "";
        style = "bg:green";
        format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
      };

      php = {
        symbol = "";
        style = "bg:green";
        format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
      };

      aws = {
        symbol = "";
        style = "bg:sapphire";
        format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
      };

      java = {
        symbol = " ";
        style = "bg:green";
        format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
      };

      kotlin = {
        symbol = "";
        style = "bg:green";
        format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
      };

      haskell = {
        symbol = "";
        style = "bg:green";
        format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
      };

      python = {
        symbol = "";
        style = "bg:green";
        format = "[[ $symbol( $version)(\\(#$virtualenv\\)) ](fg:crust bg:green)]($style)";
      };

      docker_context = {
        symbol = "";
        style = "bg:sapphire";
        format = "[[ $symbol( $context) ](fg:crust bg:sapphire)]($style)";
      };

      conda = {
        symbol = "  ";
        style = "fg:crust bg:sapphire";
        format = "[$symbol$environment ]($style)";
        ignore_base = false;
      };

      time = {
        disabled = false;
        time_format = "%R";
        style = "bg:gray";
        format = "[[  $time ](fg:white bg:gray)]($style)";
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
        mauve = "#998fe1cf";
        red = "#FF6188";
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
