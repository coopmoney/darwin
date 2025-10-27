set encoding=utf-8

" Leader
let mapleader = " "

set backspace=2   " Backspace deletes like most programs in insert mode
set nobackup
set nowritebackup
set noswapfile    " http://robots.thoughtbot.com/post/18739402579/global-gitignore#comment-458413287
set history=50
set ruler         " show the cursor position all the time
set showcmd       " display incomplete commands
set incsearch     " do incremental searching
set laststatus=2  " Always display the status line
set autowrite     " Automatically :write before running commands
set modelines=0   " Disable modelines as a security precaution
set nomodeline

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if (&t_Co > 2 || has("gui_running")) && !exists("syntax_on")
  syntax on
endif

if filereadable(expand("~/.vimrc.bundles"))
  source ~/.vimrc.bundles
endif

" Load matchit.vim, but only if the user hasn't installed a newer version.
if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
  runtime! macros/matchit.vim
endif

filetype plugin indent on

augroup vimrcEx
  autocmd!

  " When editing a file, always jump to the last known cursor position.
  " Don't do it for commit messages, when the position is invalid, or when
  " inside an event handler (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  " Set syntax highlighting for specific file types
  autocmd BufRead,BufNewFile *.md set filetype=markdown
  autocmd BufRead,BufNewFile .{jscs,jshint,eslint}rc set filetype=json
  autocmd BufRead,BufNewFile
    \ aliases.local,
    \zshenv.local,zlogin.local,zlogout.local,zshrc.local,zprofile.local,
    \*/zsh/configs/*
    \ set filetype=sh
  autocmd BufRead,BufNewFile gitconfig.local set filetype=gitconfig
  autocmd BufRead,BufNewFile tmux.conf.local set filetype=tmux
  autocmd BufRead,BufNewFile vimrc.local set filetype=vim
augroup END

" ALE linting events
augroup ale
  autocmd!

  if g:has_async
    autocmd VimEnter *
      \ set updatetime=1000 |
      \ let g:ale_lint_on_text_changed = 0
    autocmd CursorHold * call ale#Queue(0)
    autocmd CursorHoldI * call ale#Queue(0)
    autocmd InsertEnter * call ale#Queue(0)
    autocmd InsertLeave * call ale#Queue(0)
  else
    echoerr "The thoughtbot dotfiles require NeoVim or Vim 8"
  endif
augroup END

" When the type of shell script is /bin/sh, assume a POSIX-compatible
" shell for syntax highlighting purposes.
let g:is_posix = 1

" Softtabs, 2 spaces
set tabstop=2
set shiftwidth=2
set shiftround
set expandtab

" Display extra whitespace
set list listchars=tab:»·,trail:·,nbsp:·

" Use one space, not two, after punctuation.
set nojoinspaces

" Use The Silver Searcher https://github.com/ggreer/the_silver_searcher
if executable('ag')
  " Use Ag over Grep
  set grepprg=ag\ --nogroup\ --nocolor

  " Use ag in fzf for listing files. Lightning fast and respects .gitignore
  let $FZF_DEFAULT_COMMAND = 'ag --literal --files-with-matches --nocolor --hidden -g ""'

  nnoremap \ :Ag<SPACE>
endif

" Make it obvious where 80 characters is
set textwidth=80
set colorcolumn=+1

" Numbers
set number
set numberwidth=5

" Tab completion
" will insert tab at beginning of line,
" will use completion if not at beginning
set wildmode=list:longest,list:full
function! InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<Tab>"
    else
        return "\<C-p>"
    endif
endfunction
inoremap <Tab> <C-r>=InsertTabWrapper()<CR>
inoremap <S-Tab> <C-n>

" Switch between the last two files
nnoremap <Leader><Leader> <C-^>

" vim-test mappings
nnoremap <silent> <Leader>t :TestFile<CR>
nnoremap <silent> <Leader>s :TestNearest<CR>
nnoremap <silent> <Leader>l :TestLast<CR>
nnoremap <silent> <Leader>a :TestSuite<CR>
nnoremap <silent> <Leader>gt :TestVisit<CR>

" Run commands that require an interactive shell
nnoremap <Leader>r :RunInInteractiveShell<Space>

" Treat <li> and <p> tags like the block tags they are
let g:html_indent_tags = 'li\|p'

" Set tags for vim-fugitive
set tags^=.git/tags

" Open new split panes to right and bottom, which feels more natural
set splitbelow
set splitright

" Quicker window movement
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" Move between linting errors
nnoremap ]r :ALENextWrap<CR>
nnoremap [r :ALEPreviousWrap<CR>

" Map Ctrl + p to open fuzzy find (FZF)
nnoremap <c-p> :Files<cr>

" Set spellfile to location that is guaranteed to exist, can be symlinked to
" Dropbox or kept in Git and managed outside of thoughtbot/dotfiles using rcm.
set spellfile=$HOME/.vim-spell-en.utf-8.add

" Autocomplete with dictionary words when spell check is on
set complete+=kspell

" Always use vertical diffs
" set diffopt+=vertical

" copy-paste integration
set clipboard=unnamed

" Enable 24-bit true color support for better color previews
if has('termguicolors')
  set termguicolors
endif

" vim-css-color settings
" The plugin will automatically highlight colors in CSS, Sass, Less, HTML, JavaScript, and other file types
" No additional configuration needed - it works out of the box!

" Color manipulation functions
" Function to increment/decrement hex color values
function! AdjustHexColor(increment)
  let line = getline('.')
  let col = col('.')
  let hex_pattern = '#\x\{6\}\|#\x\{3\}'
  
  " Find hex color under or before cursor
  let match_start = match(line[:col], hex_pattern)
  if match_start == -1
    echo "No hex color found"
    return
  endif
  
  let hex_color = matchstr(line[match_start:], hex_pattern)
  if len(hex_color) == 4  " Convert 3-digit to 6-digit
    let hex_color = '#' . hex_color[1] . hex_color[1] . hex_color[2] . hex_color[2] . hex_color[3] . hex_color[3]
  endif
  
  " Extract RGB values
  let r = str2nr(hex_color[1:2], 16)
  let g = str2nr(hex_color[3:4], 16)
  let b = str2nr(hex_color[5:6], 16)
  
  " Adjust values
  let r = min([255, max([0, r + a:increment])])
  let g = min([255, max([0, g + a:increment])])
  let b = min([255, max([0, b + a:increment])])
  
  " Convert back to hex
  let new_hex = printf('#%02x%02x%02x', r, g, b)
  
  " Replace in line
  let new_line = substitute(line, hex_color, new_hex, '')
  call setline('.', new_line)
endfunction

" Function to cycle through color formats (hex -> rgb -> hsl)
function! CycleColorFormat()
  let line = getline('.')
  let col = col('.')
  
  " Check for hex color
  if match(line, '#\x\{6\}\|#\x\{3\}') != -1
    let hex_pattern = '#\x\{6\}\|#\x\{3\}'
    let hex_color = matchstr(line, hex_pattern)
    if len(hex_color) == 4
      let hex_color = '#' . hex_color[1] . hex_color[1] . hex_color[2] . hex_color[2] . hex_color[3] . hex_color[3]
    endif
    let r = str2nr(hex_color[1:2], 16)
    let g = str2nr(hex_color[3:4], 16)
    let b = str2nr(hex_color[5:6], 16)
    let rgb_color = 'rgb(' . r . ', ' . g . ', ' . b . ')'
    let new_line = substitute(line, hex_pattern, rgb_color, '')
    call setline('.', new_line)
  " Check for rgb color
  elseif match(line, 'rgb(\s*\d\+\s*,\s*\d\+\s*,\s*\d\+\s*)') != -1
    let rgb_pattern = 'rgb(\s*\(\d\+\)\s*,\s*\(\d\+\)\s*,\s*\(\d\+\)\s*)'
    let matches = matchlist(line, rgb_pattern)
    if len(matches) > 3
      let r = matches[1]
      let g = matches[2]
      let b = matches[3]
      let hex_color = printf('#%02x%02x%02x', r, g, b)
      let new_line = substitute(line, rgb_pattern, hex_color, '')
      call setline('.', new_line)
    endif
  endif
endfunction

" Color manipulation keybindings
" Using 'co' prefix (color operations) to avoid conflicts with NERDCommenter
" Increase brightness (all RGB channels)
nnoremap <Leader>co+ :call AdjustHexColor(16)<CR>
nnoremap <Leader>coi :call AdjustHexColor(16)<CR>
" Decrease brightness (all RGB channels)
nnoremap <Leader>co- :call AdjustHexColor(-16)<CR>
nnoremap <Leader>cod :call AdjustHexColor(-16)<CR>
" Cycle color format (hex -> rgb -> hex)
nnoremap <Leader>coc :call CycleColorFormat()<CR>

" Alternative shortcuts without Leader key
" ] and [ with c for color adjustments
nnoremap ]c :call AdjustHexColor(8)<CR>
nnoremap [c :call AdjustHexColor(-8)<CR>
nnoremap gc :call CycleColorFormat()<CR>

" Quick color adjustments for hex colors under cursor
" Alt+Up/Down to adjust brightness (if your terminal supports it)
nnoremap <M-Up> :call AdjustHexColor(8)<CR>
nnoremap <M-Down> :call AdjustHexColor(-8)<CR>

" Local config
if filereadable($HOME . "/.vimrc.local")
  source ~/.vimrc.local
endif
