{ config, pkgs, lib, ... }:

{
  programs.zsh = {
    enable = true;

    # History configuration
    history = {
      size = 4096;
      save = 4096;
      path = "${config.home.homeDirectory}/.zhistory";
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      extended = true;
      share = true;
    };

    # Shell options
    autocd = true;
    defaultKeymap = "emacs";

    # Environment variables
    sessionVariables = {
      EDITOR = "vim";
      VISUAL = "vim";
      ERL_AFLAGS = "-kernel shell_history enabled";
    };

    # Shell aliases
    shellAliases = {
      # Unix basics
      ls = "eza --color=always --group-directories-first --icons";
      ll = "ls -la";
      la = "ls -a";
      lt = "ls --tree --level=2";
      ln = "ln -v";
      mkdir = "mkdir -p";
      e = "$EDITOR";
      v = "$VISUAL";

      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
      "-" = "cd -";
      dev = "cd ~/Developer";
      cdr = ''cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)"'';

      # Docker
      dcu = "docker compose up -d";
      dcd = "docker compose down";
      dockercpu = ''docker stats --no-stream --format 'table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}' '';

      # Chamber (AWS)
      chamberr = "aws-vault exec dmadmin -- chamber read";
      chamberw = "aws-vault exec dmadmin -- chamber write";
      chamberl = "aws-vault exec dmadmin -- chamber list";
      lkr = "aws-vault exec dmadmin -- chamber read locker";
      lkw = "aws-vault exec dmadmin -- chamber write locker";
      lkl = "aws-vault exec dmadmin -- chamber list locker";

      # Applications
      curs = "cursor editor";
      curse = "cursor editor";
      eternal = "et --terminal-path /opt/homebrew/bin/etterminal";

      # Git aliases (replacing oh-my-zsh git plugin)
      gst = "git status";
      ga = "git add";
      gaa = "git add --all";
      gc = "git commit";
      "gc!" = "git commit --amend";
      gco = "git checkout";
      gcb = "git checkout -b";
      gcp = "git cherry-pick";
      gd = "git diff";
      gf = "git fetch";
      gl = "git pull";
      gp = "git push";
      gr = "git remote";
      grb = "git rebase";
      grhh = "git reset HEAD --hard";
      glog = "git log --oneline --decorate --graph";
      gsb = "git status -sb";
      gsh = "git show";
      gss = "git status -s";

      # Utilities
      path = ''echo $PATH | tr -s ":" "\n"'';
      "alias?" = "alias | grep";
      reload = "source ~/.zshrc";

      # Chrome proxy
      chromeproxy = ''open -a "Google Chrome Canary" --args --proxy-server=http://brd.superproxy.io:33335 --proxy-auth=brd-customer-hl_98d82783-zone-isp_proxy2-ip-185.81.174.66:7gysc1ewowwh --host-resolver-rules="MAP * ~NOTFOUND , EXCLUDE brd.superproxy.io"'';
    };

    # Oh-my-zsh configuration
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "docker"
        "kubectl"
        "aws"
        "colored-man-pages"
        "command-not-found"
        "fzf"
      ];
      theme = "robbyrussell"; # Will be overridden by starship
    };

    # Zsh plugins
    plugins = [
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users/zsh-syntax-highlighting";
          repo = "zsh-syntax-highlighting";
          rev = "0.7.1";
          sha256 = "03r6hpb5fy4yaakqm3lbf4xcvd408r44jgpv4lnzl9asp4sb9qc0";
        };
      }
      {
        name = "zsh-autosuggestions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users/zsh-autosuggestions";
          repo = "zsh-autosuggestions";
          rev = "v0.7.0";
          sha256 = "0z6i9wjjklb4lvr7zjhbphibsyx51psv50gm07mbb0kj9058j6kc";
        };
      }
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

    # Init content
    initContent = ''
      # Enable Powerlevel10k instant prompt
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi

      # Load p10k config
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

      # Load custom functions (excluding disabled ones)
      if [ -d "$HOME/.zsh/functions" ]; then
        for function in ~/.zsh/functions/*; do
          if [[ -f "$function" && ! "$function" =~ \.disabled$ ]]; then
            source "$function"
          fi
        done
      fi

      # Options
      setopt autocd autopushd pushdminus pushdsilent pushdtohome cdablevars
      DIRSTACKSIZE=5
      setopt extendedglob
      unsetopt nomatch
      setopt hist_ignore_all_dups inc_append_history

      # Keybindings
      bindkey -e  # Emacs key bindings
      bindkey '^r' history-incremental-search-backward
      bindkey '^[[A' up-line-or-search
      bindkey '^[[B' down-line-or-search

      # Directory colors
      export CLICOLOR=1
      export LSCOLORS=ExFxBxDxCxegedabagacad

      # FZF configuration
      if command -v fzf &> /dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_DEFAULT_OPTS='
          --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
          --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
          --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
        '
      fi

      # Node/NPM
      export NPM_PACKAGES="$HOME/.npm-packages"
      export PATH="$NPM_PACKAGES/bin:$PATH"
      export NODE_PATH="$NPM_PACKAGES/lib/node_modules"

      # Web search function
      web_search() {
        emulate -L zsh
        local engine="google"
        local query=""

        if [[ $# -gt 1 ]]; then
          engine="$1"
          shift
          query="$*"
        else
          query="$*"
        fi

        case $engine in
          google) open "https://www.google.com/search?q=''${query// /+}" ;;
          github) open "https://github.com/search?q=''${query// /+}" ;;
          ddg|duckduckgo) open "https://www.duckduckgo.com/?q=''${query// /+}" ;;
          *) echo "Search engine $engine not supported." ;;
        esac
      }
      alias google='web_search google'
      alias github='web_search github'
      alias ddg='web_search duckduckgo'

      # Toggle hidden files in Finder
      togglefinderfiles() {
        STATUS=$(defaults read com.apple.finder AppleShowAllFiles 2>/dev/null || echo "FALSE")
        if [ "$STATUS" = "TRUE" ]; then
          defaults write com.apple.finder AppleShowAllFiles FALSE
          echo "Hidden files are now invisible."
        else
          defaults write com.apple.finder AppleShowAllFiles TRUE
          echo "Hidden files are now visible."
        fi
        killall Finder
      }

      # Auto-Warpify
      printf '\eP$f{"hook": "SourcedRcFileForWarp", "value": { "shell": "zsh"}}\x9c'

      # Load local config if exists
      [[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
    '';

    # Completion
    enableCompletion = true;
    completionInit = ''
      # Case insensitive completion
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

      # Colorful completions
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}

      # Load custom completions
      if [ -d "$HOME/.zsh/completion" ]; then
        fpath=($HOME/.zsh/completion $fpath)
      fi

      autoload -Uz compinit && compinit
    '';
  };

  # Install zsh completions and functions
  # TODO: Fix the relative path issue - for now, keep using existing files
  # The functions and completions will continue to work from their existing locations
}
