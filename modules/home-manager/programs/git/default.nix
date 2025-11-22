{ config, pkgs, lib, fullName, email, gitKey, ... }:

{
  programs.git = {
    enable = true;

    signing = {
      signByDefault = true;
      key = gitKey;
    };

    # Git configuration
    settings = {
      user = {
        name = fullName;
        email = email;
      };
      # Ensure Git uses the same CA bundle (helps user-invoked Git outside Nix)
      http.sslCAInfo = "/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt";
      init = {
        defaultBranch = "main";
        templatedir = "~/.git_template";
      };

      core = {
        autocrlf = "input";
        editor = "vim";
        excludesfile = "${config.xdg.configHome}/git/ignore";
      };

      color = {
        ui = "auto";
      };

      diff = {
        colorMoved = "zebra";
        tool = "vimdiff";
      };

      merge = {
        ff = false;
        tool = "sublimerge";
      };

      push = {
        default = "current";
      };

      pull = {
        rebase = false;
      };

      fetch = {
        prune = true;
      };

      rebase = {
        autosquash = true;
      };

      commit = {
        template = "${config.xdg.configHome}/git/message";
      };

      gpg = {
        format = "ssh";
        ssh = {
          program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
        };
      };

      # Git LFS
      filter.lfs = {
        clean = "git-lfs clean -- %f";
        process = "git-lfs filter-process";
        required = true;
        smudge = "git-lfs smudge -- %f";
      };

      # Aliases
      alias = {
      # Shortcuts
      aa = "add --all";
      ap = "add --patch";
      ci = "commit -v";
      co = "checkout";
      pf = "push --force-with-lease";
      st = "status";
      br = "branch";

      # Branch management
      branches = "for-each-ref --sort=-committerdate --format='%(color:blue)%(authordate:relative)\t%(color:red)%(authorname)\t%(color:white)%(color:bold)%(refname:short)' refs/remotes";
      recent = "branch --sort=-committerdate --format='%(committerdate:relative)%09%(refname:short)'";

      # Logging
      lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      ll = "log --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --numstat";

      # Working with remotes
      up = "!git pull --rebase --prune $@ && git submodule update --init --recursive";

      # Undo
      undo = "reset HEAD~1 --mixed";
      amend = "commit -a --amend";

      # Show current branch
      current-branch = "rev-parse --abbrev-ref HEAD";

      # Cleanup
      cleanup = "!git branch --merged | grep -v '\\*' | xargs -n 1 git branch -d";
      };
    };
  };

  # Use delta for diffs
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      line-numbers = true;
      # Let catppuccin handle the theme
      decorations = {
        commit-decoration-style = "bold yellow box ul";
        file-style = "bold yellow ul";
        file-decoration-style = "none";
      };
    };
  };

  # Git ignore patterns
  programs.git.ignores = [
      # macOS
      ".DS_Store"
      "._*"
      ".Spotlight-V100"
      ".Trashes"

      # Vim
      "*.swp"
      "*.swo"
      "*~"
      ".netrwhist"

      # VS Code
      ".vscode/"
      "*.code-workspace"
      ".history/"

      # Direnv
      ".direnv/"
      ".envrc"

      # Node
      "node_modules/"
      "npm-debug.log*"
      "yarn-debug.log*"
      "yarn-error.log*"
      ".pnpm-debug.log*"

      # Python
      "__pycache__/"
      "*.py[cod]"
      "*$py.class"
      ".Python"
      "venv/"
      ".venv/"

      # Terraform
      ".terraform/"
      "*.tfstate"
      "*.tfstate.*"

      # General
      "*.log"
      ".env"
      ".env.local"
      ".env.*.local"

      # AWS
      ".aws-sam/"
  ];

  # Git message template
  xdg.configFile."git/message".text = ''


    # 50-character subject line
    #
    # 72-character wrapped longer description. This should answer:
    #
    # * Why was this change necessary?
    # * How does it address the problem?
    # * Are there any side effects?
    #
    # Include a link to the ticket, if any.
  '';
}
