{ pkgs, ... }:

{
  # Git configuration migrated from ~/dotfiles/gitconfig
  programs.git = {
    enable = true;

    # These can be overridden in local.nix per-machine
    userName = "Cooper Maruyama";
    userEmail = "cooper@darkmatter.io";

    # Aliases from gitconfig
    aliases = {
      aa = "add --all";
      ap = "add --patch";
      branches = "for-each-ref --sort=-committerdate --format=\\\"%(color:blue)%(authordate:relative)\\t%(color:red)%(authorname)\\t%(color:white)%(color:bold)%(refname:short)\\\" refs/remotes";
      ci = "commit -v";
      co = "checkout";
      pf = "push --force-with-lease";
      st = "status";
    };

    extraConfig = {
      init = {
        defaultBranch = "main";
        templatedir = "~/.git_template";
      };

      push = {
        default = "current";
      };

      color = {
        ui = "auto";
      };

      core = {
        excludesfile = "$HOME/.gitignore_global";
        autocrlf = "input";
        editor = "vim";
      };

      commit = {
        template = "~/.gitmessage";
        gpgsign = true;
      };

      fetch = {
        prune = true;
      };

      rebase = {
        autosquash = true;
      };

      merge = {
        ff = false;
        tool = "sublimerge";
      };

      diff = {
        colorMoved = "zebra";
      };

      # GPG signing with 1Password
      gpg = {
        format = "ssh";
        ssh = {
          program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
        };
      };

      user = {
        signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA+M/DHDlKgayM6wsiX6r704pE+2qENOsKcytC7sBhKA";
      };

      # Git LFS
      filter.lfs = {
        required = true;
        clean = "git-lfs clean -- %f";
        smudge = "git-lfs smudge -- %f";
        process = "git-lfs filter-process";
      };

      # Optional: Use SSH instead of HTTPS for GitHub (uncomment if desired)
      # url."git@github.com:" = {
      #   insteadOf = "https://github.com/";
      # };
    };

    # Include machine-specific git config
    includes = [
      { path = "~/.gitconfig.local"; }
    ];
  };

  # Ensure git-lfs is available (Home Manager context)
  home.packages = with pkgs; [
    git-lfs
  ];
}
