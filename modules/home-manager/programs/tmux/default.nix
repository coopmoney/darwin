{ config, pkgs, lib, ... }:

{
  programs.tmux = {
    enable = true;

    # Basic settings
    baseIndex = 1;
    clock24 = false;
    escapeTime = 500;
    historyLimit = 10000;
    keyMode = "vi";
    mouse = false;
    terminal = "screen-256color";

    # Use Ctrl-s as secondary prefix
    prefix = "C-b";

    # Plugins
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      pain-control
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavour 'mocha'
          set -g @catppuccin_window_tabs_enabled on
          set -g @catppuccin_date_time "%Y-%m-%d %H:%M"
        '';
      }
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-vim 'session'
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-boot 'on'
          set -g @continuum-save-interval '10'
        '';
      }
    ];

    # Extra configuration
    extraConfig = ''
      # Set secondary prefix to Ctrl-s
      set -g prefix2 C-s

      # Enable focus events
      set -g focus-events on

      # Window options
      setw -g aggressive-resize off
      setw -g pane-base-index 1

      # Status bar
      set -g status-position bottom
      set -g status-justify left

      # Vi mode keys
      setw -g mode-keys vi
      set -g status-keys vi

      # Key bindings - vim navigation
      bind-key h select-pane -L
      bind-key j select-pane -D
      bind-key k select-pane -U
      bind-key l select-pane -R
      bind-key -r C-h select-window -t :-
      bind-key -r C-l select-window -t :+

      # Split panes using | and -
      bind | split-window -h
      bind - split-window -v
      unbind '"'
      unbind %

      # Reload config
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded..."

      # Copy mode vi bindings
      bind-key -T copy-mode-vi 'v' send -X begin-selection
      bind-key -T copy-mode-vi 'y' send -X copy-selection-and-cancel
      bind-key -T copy-mode-vi 'Enter' send -X copy-selection-and-cancel

      # macOS specific settings
      ${lib.optionalString pkgs.stdenv.isDarwin ''
        # Copy-paste integration
        set-option -g default-command "reattach-to-user-namespace -l ${pkgs.zsh}/bin/zsh"

        # Copy to system clipboard
        bind-key -T copy-mode-vi 'y' send -X copy-pipe-and-cancel "reattach-to-user-namespace pbcopy"
        bind-key -T copy-mode-vi 'Enter' send -X copy-pipe-and-cancel "reattach-to-user-namespace pbcopy"

        # Paste from system clipboard
        bind ] run "reattach-to-user-namespace pbpaste | tmux load-buffer - && tmux paste-buffer"
      ''}

      # Don't suspend-client
      unbind-key C-z

      # Quick pane switching
      bind -r ^ last-window
      bind -r k select-pane -U
      bind -r j select-pane -D
      bind -r h select-pane -L
      bind -r l select-pane -R

      # Resize panes
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Create new windows/panes in same directory
      bind c new-window -c "#{pane_current_path}"
      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"

      # Activity monitoring
      setw -g monitor-activity on
      set -g visual-activity off

      # Renumber windows sequentially after closing any of them
      set -g renumber-windows on

      # Display pane numbers for longer
      set -g display-panes-time 2000

      # Messages display time
      set -g display-time 3000

      # Load local config if exists
      if-shell "[ -f ~/.tmux.conf.local ]" 'source ~/.tmux.conf.local'
    '';
  };

  # Create tmux config directory
  xdg.configFile."tmux/.keep".text = "";
}
