{ pkgs, ... }:

{
  # Zsh configuration migrated from ~/dotfiles/zshrc and aliases
  programs.zsh = {
    enable = true;
    
    # Shell aliases from ~/dotfiles/aliases
    shellAliases = {
      # Unix
      ls = "gls --color=auto";
      ll = "ls -al";
      ln = "ln -v";
      mkdir = "mkdir -p";
      e = "$EDITOR";
      v = "$VISUAL";
      
      # Easier navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
      "-" = "cd -";
      
      # Pretty print the path
      path = "echo $PATH | tr -s ':' '\\n'";
      
      # Find aliases containing word
      "alias?" = "alias | grep";
      
      # Change directory to git root
      cdr = "cd \"$(git rev-parse --show-toplevel)\"";
      
      # Docker
      dcu = "docker compose up -d";
      dcd = "docker compose down";
    };
    
    # Zsh initialization (from zshrc)
    initExtra = ''
      # Load custom executable functions
      if [ -d "$HOME/.zsh/functions" ]; then
        for function in ~/.zsh/functions/*; do
          [ -f "$function" ] && source "$function"
        done
      fi
      
      # Load custom configs
      _load_settings() {
        _dir="$1"
        if [ -d "$_dir" ]; then
          # Pre configs
          if [ -d "$_dir/pre" ]; then
            for config in "$_dir"/pre/**/*~*.zwc(N-.); do
              . $config
            done
          fi
          
          # Main configs
          for config in "$_dir"/**/*(N-.); do
            case "$config" in
              "$_dir"/(pre|post)/*|*.zwc)
                :
                ;;
              *)
                . $config
                ;;
            esac
          done
          
          # Post configs
          if [ -d "$_dir/post" ]; then
            for config in "$_dir"/post/**/*~*.zwc(N-.); do
              . $config
            done
          fi
        fi
      }
      
      _load_settings "$HOME/.zsh/configs"
      
      # Direnv hook
      if command -v direnv &>/dev/null; then
        eval "$(direnv hook zsh)"
      fi
      
      # Aliases
      [ -f ~/.aliases ] && source ~/.aliases
      
      # Local config (machine-specific)
      [ -f ~/.zshrc.local ] && source ~/.zshrc.local
    '';
    
    # Environment variables (from zshenv)
    envExtra = ''
      # Editor
      export EDITOR="vim"
      export VISUAL="vim"
      
      # Local config
      [ -f ~/.zshenv.local ] && source ~/.zshenv.local
    '';
    
    # Enable completion
    enableCompletion = true;
    
    # Suggestion plugins
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;
  };
  
  # Set zsh as default shell
  environment.shells = [ pkgs.zsh ];
  
  # Environment variables
  environment.variables = {
    EDITOR = "vim";
    VISUAL = "vim";
  };
}