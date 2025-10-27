{ pkgs, ... }:

{
  # Tmux configuration migrated from ~/dotfiles/tmux.conf
  programs.tmux = {
    enable = true;

    # Improve colors
    terminal = "screen-256color";

    # Use zsh as default shell
    shell = "${pkgs.zsh}/bin/zsh";

    # Vi mode
    keyMode = "vi";

    # Start window numbers at 1
    baseIndex = 1;

    # Renumber windows sequentially after closing any of them
    # renumberWindows = true;

    # Increase scrollback lines
    historyLimit = 10000;

    # Extra configuration from tmux.conf
    extraConfig = ''
      # Set prefix2 to Ctrl-s
      set -g prefix2 C-s

      # Start pane numbers at 1
      set-window-option -g pane-base-index 1

      # Act like vim
      bind-key h select-pane -L
      bind-key j select-pane -D
      bind-key k select-pane -U
      bind-key l select-pane -R
      bind-key -r C-h select-window -t :-
      bind-key -r C-l select-window -t :+

      # Soften status bar color from harsh green to light gray
      set -g status-style bg='#666666',fg='#aaaaaa'

      # Remove administrative debris (session name, hostname, time) in status bar
      set -g status-left \'\'
      set -g status-right \'\'

      # Prefix -> back-one-character
      bind-key C-b send-prefix
      # Prefix-2 -> forward-incremental-history-search
      bind-key C-s send-prefix -2

      # Copy-paste integration
      set-option -g default-command "reattach-to-user-namespace -l ${pkgs.zsh}/bin/zsh"

      # Setup 'v' to begin selection as in Vim
      bind-key -Tcopy-mode-vi 'v' send -X begin-selection
      bind-key -Tcopy-mode-vi 'y' send -X copy-selection

      # Update default binding of Enter to also use copy-pipe
      unbind -Tcopy-mode-vi 'Enter'
      bind-key -Tcopy-mode-vi 'Enter' send -X copy-selection

      # Bind ']' to use pbpaste
      bind ] run "reattach-to-user-namespace pbpaste | tmux load-buffer - && tmux paste-buffer"

      # Don't suspend-client
      unbind-key C-z

      # Local config
      if-shell "[ -f ~/.tmux.conf.local ]" 'source ~/.tmux.conf.local'
    '';
  };

  # Ensure reattach-to-user-namespace is available for clipboard support (Home Manager context)
  home.packages = with pkgs; [
    reattach-to-user-namespace
  ];
}
