{ config, pkgs, lib, ... }:

{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;

    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--inline-info"
      "--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8"
      "--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc"
      "--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
    ];

    fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
    fileWidgetOptions = [
      "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
    ];

    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
    changeDirWidgetOptions = [
      "--preview 'tree -C {} | head -200'"
    ];

    historyWidgetOptions = [
      "--sort"
      "--exact"
    ];
  };

  # Additional FZF functions
  programs.zsh.initContent = lib.mkAfter ''
    # FZF git helpers

    # fbr - checkout git branch
    fbr() {
      local branches branch
      branches=$(git --no-pager branch -vv) &&
      branch=$(echo "$branches" | fzf +m) &&
      git checkout $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
    }

    # fco - checkout git branch/tag
    fco() {
      local tags branches target
      branches=$(
        git --no-pager branch --all \
          --format="%(if)%(HEAD)%(then)%(else)%(if:equals=HEAD)%(refname:strip=3)%(then)%(else)%1B[0;34;1mbranch%09%1B[m%(refname:short)%(end)%(end)" \
        | sed '/^$/d') || return
      tags=$(
        git --no-pager tag | awk '{print "\x1b[35;1mtag\x1b[m\t" $1}') || return
      target=$(
        (echo "$branches"; echo "$tags") |
        fzf --no-hscroll --no-multi -n 2 \
            --ansi --preview="git --no-pager log -150 --pretty=format:%s '..{2}'") || return
      git checkout $(awk '{print $2}' <<<"$target" )
    }

    # fkill - kill processes
    fkill() {
      local pid
      if [ "$UID" != "0" ]; then
        pid=$(ps -f -u $UID | sed 1d | fzf -m | awk '{print $2}')
      else
        pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
      fi

      if [ "x$pid" != "x" ]; then
        echo $pid | xargs kill -''${1:-9}
      fi
    }

    # fe - open file in editor
    fe() {
      IFS=$'\n' files=($(fzf-tmux --query="$1" --multi --select-1 --exit-0))
      [[ -n "$files" ]] && ''${EDITOR:-vim} "''${files[@]}"
    }
  '';
}
