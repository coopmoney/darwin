{ config, pkgs, lib, ... }:

# Simple Apathy colorscheme for Neovim derived from your VS Code theme
# If you later publish a machine-readable palette, we can auto-generate this.

let
  colorsLua = pkgs.writeText "apathy-colors.lua" ''
    local M = {}
    M.colors = {
      bg = "#0e0b13",
      fg = "#e3e1e8c8",
      comment = "#4D4A56",

      red = "#e60063",
      green = "#b1d36d",
      yellow = "#FFCB6B",
      blue = "#82AAFF",
      magenta = "#C792EA",
      cyan = "#89DDFF",
      orange = "#ffb547",

      gutter = "#0c0a10",
      cursorline = "#17121c",
      selection = "#2d22476b",
    }
    return M
  '';

  themeLua = pkgs.writeText "apathy.lua" ''
    local p = require('apathy.colors').colors

    vim.cmd('highlight clear')
    if vim.fn.exists('syntax_on') == 1 then
      vim.cmd('syntax reset')
    end
    vim.g.colors_name = 'apathy'

    local function hi(group, opts)
      local cmd = 'hi ' .. group
      if opts.fg then cmd = cmd .. ' guifg=' .. opts.fg end
      if opts.bg then cmd = cmd .. ' guibg=' .. opts.bg end
      if opts.sp then cmd = cmd .. ' guisp=' .. opts.sp end
      if opts.style then cmd = cmd .. ' gui=' .. opts.style end
      vim.cmd(cmd)
    end

    -- Core UI
    hi('Normal',        { fg = p.fg, bg = p.bg })
    hi('Comment',       { fg = p.comment, style = 'italic' })
    hi('CursorLine',    { bg = p.cursorline })
    hi('CursorLineNr',  { fg = p.yellow, style = 'bold' })
    hi('LineNr',        { fg = p.blue })
    hi('Visual',        { bg = p.selection })
    hi('Search',        { fg = p.bg, bg = p.yellow })
    hi('IncSearch',     { fg = p.bg, bg = p.magenta })
    hi('Pmenu',         { fg = p.fg, bg = p.gutter })
    hi('PmenuSel',      { fg = p.bg, bg = p.blue })
    hi('SignColumn',    { bg = p.bg })

    -- Diagnostics
    hi('DiagnosticError', { fg = p.red })
    hi('DiagnosticWarn',  { fg = p.yellow })
    hi('DiagnosticInfo',  { fg = p.blue })
    hi('DiagnosticHint',  { fg = p.cyan })

    -- Git signs
    hi('GitSignsAdd',    { fg = p.green })
    hi('GitSignsChange', { fg = p.yellow })
    hi('GitSignsDelete', { fg = p.red })

    -- Treesitter highlights (common subset)
    hi('@function', { fg = p.orange })
    hi('@method',   { fg = p.orange })
    hi('@variable', { fg = p.fg })
    hi('@constant', { fg = p.magenta })
    hi('@string',   { fg = p.green })
    hi('@keyword',  { fg = p.blue })
    hi('@type',     { fg = p.orange })
  '';

in {
  xdg.configFile."nvim/lua/apathy/colors.lua".source = colorsLua;
  xdg.configFile."nvim/colors/apathy.lua".source = themeLua;
}
