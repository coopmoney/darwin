{ config, ... }:

{
  programs.lazygit = {
    enable = true;

    settings = {
      gui = {
        # Catppuccin theme colors
        theme = {
          activeBorderColor = [ "#89b4fa" "bold" ];
          inactiveBorderColor = [ "#a6adc8" ];
          optionsTextColor = [ "#89b4fa" ];
          selectedLineBgColor = [ "#313244" ];
          cherryPickedCommitBgColor = [ "#45475a" ];
          cherryPickedCommitFgColor = [ "#89b4fa" ];
          unstagedChangesColor = [ "#f38ba8" ];
          defaultFgColor = [ "#cdd6f4" ];
          searchingActiveBorderColor = [ "#f9e2af" ];
        };

        showFileTree = true;
        showListFooter = true;
        showRandomTip = true;
        showCommandLog = true;
        commandLogSize = 8;
        splitDiff = "auto";
        skipDiscardChangeWarning = false;
        skipStashWarning = false;
        showBottomLine = true;

        # Window size
        screenMode = "normal";

        # Border style
        border = "rounded";

        # Time format
        timeFormat = "02 Jan 06";
        shortTimeFormat = "3:04PM";
      };

      git = {
        pagers = [{
          colorArg = "always";
          pager = "delta --dark --paging=never";
        }];

        pull = {
          mode = "rebase";
        };

        push = {
          auto = false;
        };

        commit = {
          signOff = false;
        };

        merging = {
          manualCommit = false;
          args = "";
        };

        skipHookPrefix = "WIP";

        mainBranches = [ "master" "main" ];

        autoFetch = true;
        autoRefresh = true;

        branchLogCmd = "git log --graph --color=always --abbrev-commit --decorate --date=relative --pretty=medium {{branchName}} --";

        overrideGpg = false;
      };

      refresher = {
        refreshInterval = 10;
        fetchInterval = 60;
      };

      update = {
        method = "prompt";
      };

      confirmOnQuit = false;

      keybinding = {
        universal = {
          quit = "q";
          quit-alt1 = "<c-c>";
          return = "<esc>";
          quitWithoutChangingDirectory = "Q";
          togglePanel = "<tab>";
          prevItem = "<up>";
          nextItem = "<down>";
          prevItem-alt = "k";
          nextItem-alt = "j";
          prevPage = ",";
          nextPage = ".";
          scrollLeft = "H";
          scrollRight = "L";
          gotoTop = "<";
          gotoBottom = ">";
          toggleRangeSelect = "v";
          rangeSelectDown = "<s-down>";
          rangeSelectUp = "<s-up>";
          prevBlock = "<left>";
          nextBlock = "<right>";
          prevBlock-alt = "h";
          nextBlock-alt = "l";
          nextBlock-alt2 = "<tab>";
          prevBlock-alt2 = "<backtab>";
          jumpToBlock = ["1" "2" "3" "4" "5"];
          nextMatch = "n";
          prevMatch = "N";
          startSearch = "/";
          optionMenu = "x";
          optionMenu-alt1 = "?";
          select = "<space>";
          goInto = "<enter>";
          confirm = "<enter>";
          confirmInEditor = "<a-enter>";
          remove = "d";
          new = "n";
          edit = "e";
          openFile = "o";
          scrollUpMain = "<pgup>";
          scrollDownMain = "<pgdown>";
          scrollUpMain-alt1 = "K";
          scrollDownMain-alt1 = "J";
          scrollUpMain-alt2 = "<c-u>";
          scrollDownMain-alt2 = "<c-d>";
          executeShellCommand = ":";
          createRebaseOptionsMenu = "m";
          pushFiles = "P";
          pullFiles = "p";
          refresh = "R";
          createPatchOptionsMenu = "<c-p>";
          nextTab = "]";
          prevTab = "[";
          nextScreenMode = "+";
          prevScreenMode = "_";
          undo = "z";
          redo = "<c-z>";
          filteringMenu = "<c-s>";
          diffingMenu = "W";
          diffingMenu-alt = "<c-e>";
          copyToClipboard = "<c-o>";
          openRecentRepos = "<c-r>";
          submitEditorText = "<enter>";
          extrasMenu = "@";
          toggleWhitespaceInDiffView = "<c-w>";
          increaseContextInDiffView = "}";
          decreaseContextInDiffView = "{";
        };
      };

      os = {
        editPreset = "nvim";
      };

      disableStartupPopups = false;

      customCommands = [
        {
          key = "<c-f>";
          command = "git fetch {{.Form.Remote}} {{.Form.LocalBranch}}:{{.Form.RemoteBranch}} && git status";
          context = "localBranches";
          prompts = [
            {
              type = "input";
              title = "Remote:";
              key = "Remote";
              initialValue = "{{.SelectedLocalBranch.Remote}}";
            }
            {
              type = "input";
              title = "Local branch:";
              key = "LocalBranch";
              initialValue = "{{.SelectedLocalBranch.Name}}";
            }
            {
              type = "input";
              title = "Remote branch:";
              key = "RemoteBranch";
              initialValue = "{{.SelectedLocalBranch.Name}}";
            }
          ];
        }
      ];
    };
  };
}
