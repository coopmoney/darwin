{ config, pkgs, lib, inputs, ... }:

let
  nixvim = inputs.nixvim;
  
  # gp.nvim: LLM assistant supporting OpenAI, Anthropic, Ollama
  gp-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "gp-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "Robitx";
      repo = "gp.nvim";
      rev = "v3.9.0";
      sha256 = "sha256-3tfhahQZPBYbAnRQXtMAnfwr4gH7mdjxtB8ZqrU3au4=";
    };
  };
in
{
  imports = [ nixvim.homeModules.nixvim ];

  # Core CLI dependencies for the Neovim UX
  home.packages = with pkgs; [
    ripgrep fd fzf git lazygit

    # LLM support & local models
    _1password-cli ollama curl

    # JavaScript / TypeScript
    biome
    nodejs_22
    nodePackages.typescript
    nodePackages.typescript-language-server

    # Go
    go gopls gofumpt gotools golangci-lint

    # Python
    python312
    ruff
    basedpyright

    # Shell
    shellcheck shfmt bash-language-server

    # Nix
    nil alejandra statix deadnix

    # Lua (for Neovim config)
    lua-language-server
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # UI defaults and theme
    extraConfigLua = ''
      vim.o.termguicolors = true
      vim.o.number = true
      vim.o.relativenumber = true
      vim.o.signcolumn = "yes"
      vim.o.updatetime = 200
      vim.o.timeoutlen = 400
      vim.g.mapleader = " "

      -- Load Apathy colors
      pcall(function() vim.cmd("colorscheme apathy") end)
    '';

    # Plugins
    plugins = {
      which-key.enable = true;
      lualine.enable = true;
      gitsigns.enable = true;

      oil.enable = true;
      telescope.enable = true;

      # NOTE: Treesitter configuration is temporarily disabled pending nixvim schema update

      luasnip.enable = true;

      # LSP
      lsp = {
        enable = true;
        servers = {
          # Prefer vtsls over tsserver
          vtsls.enable = true;
          gopls.enable = true;
          basedpyright.enable = true;
          bashls.enable = true;
          nil_ls.enable = true;
          lua_ls.enable = true;
          ruff_lsp = {
            enable = true;
            package = null; # managed externally / via pip; avoid nixvim package lookup
          };
        };
        keymaps.lspBuf = {
          "gd" = "definition";
          "gr" = "references";
          "gD" = "declaration";
          "gi" = "implementation";
          "K"  = "hover";
          "<leader>rn" = "rename";
          "<leader>ca" = "code_action";
        };
        keymaps.diagnostic = {
          "[d" = "goto_prev";
          "]d" = "goto_next";
          "<leader>e" = "open_float";
          "<leader>q" = "setloclist";
        };
      };

    };

    # Keymaps
    keymaps = [
      { mode = "n"; key = "<leader>ff"; action = "<cmd>Telescope find_files<cr>"; options.desc = "Find files"; }
      { mode = "n"; key = "<leader>fg"; action = "<cmd>Telescope live_grep<cr>"; options.desc = "Live grep"; }
      { mode = "n"; key = "<leader>fb"; action = "<cmd>Telescope buffers<cr>"; options.desc = "Buffers"; }
      { mode = "n"; key = "<leader>fh"; action = "<cmd>Telescope help_tags<cr>"; options.desc = "Help"; }

      { mode = "n"; key = "-"; action = "<cmd>Oil<cr>"; options.desc = "Oil (parent dir)"; }

      { mode = "n"; key = "<leader>F"; action = "<cmd>lua require('conform').format({ async = true })<cr>"; options.desc = "Format buffer"; }
      { mode = "n"; key = "<leader>L"; action = "<cmd>lua require('lint').try_lint()<cr>"; options.desc = "Lint buffer"; }
    ];

    # Extra plugins
    extraPlugins = [ gp-nvim ];

    # gp.nvim configuration and keymaps (appended to extraConfigLua)
    extraConfigLuaPost = ''
      local ok_gp, gp = pcall(require, 'gp')
      if ok_gp then
        gp.setup({
          providers = {
            openai = {
              endpoint = os.getenv('OPENAI_API_BASE') or 'https://api.openai.com/v1',
              secret = os.getenv('OPENAI_API_KEY'),
              models = { 'gpt-4o-mini', 'gpt-4o' },
            },
            anthropic = {
              endpoint = os.getenv('ANTHROPIC_API_BASE') or 'https://api.anthropic.com',
              secret = os.getenv('ANTHROPIC_API_KEY'),
              models = { 'claude-3-5-sonnet-latest', 'claude-3-5-haiku-latest' },
            },
            ollama = {
              endpoint = os.getenv('OLLAMA_HOST') or 'http://127.0.0.1:11434',
              models = { 'qwen2.5-coder:7b', 'llama3.1:8b' },
            },
          },
          prefer = { 'openai', 'anthropic', 'ollama' },
        })

        local map = vim.keymap.set
        map({ 'n', 'v' }, '<leader>la', '<cmd>GpChatToggle<cr>', { desc = 'LLM: Chat' })
        map('v', '<leader>le', ':<C-u>GpExplain<cr>', { desc = 'LLM: Explain selection' })
        map('n', '<leader>le', '<cmd>GpExplain<cr>', { desc = 'LLM: Explain buffer' })
        map('v', '<leader>lc', ':<C-u>GpCode<cr>', { desc = 'LLM: Code transform' })
        map('n', '<leader>lo', '<cmd>GpProvider openai<cr>', { desc = 'LLM: Use OpenAI' })
        map('n', '<leader>ll', '<cmd>GpProvider ollama<cr>', { desc = 'LLM: Use Ollama' })
        map('n', '<leader>lt', '<cmd>GpProvider anthropic<cr>', { desc = 'LLM: Use Anthropic' })
      end
    '';
  };
}
