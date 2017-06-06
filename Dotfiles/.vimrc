" vim: set sw=2 ts=2 sts=2 et tw=78 foldmarker={,} foldlevel=0 foldmethod=marker spell:

" Load the plugins {
  if filereadable(expand("~/.vimrc.bundles"))
    source ~/.vimrc.bundles
  endif
" }

" Colors {
  syntax enable           " enable syntax processing
  colorscheme molokai
  let g:molokai_original = 1
  let g:rehash256 = 1
" }

" Key Mapping {
  " Swap 0 and ^. I tend to want to jump to the first non-whitespace character
  nnoremap 0 ^
  nnoremap ^ 0

  " Terminal sees <C-@> as <C-space>
  " nnoremap <C-@> <Esc>:noh<CR>

  " Hightlight last inserted text, visually selects the block of characters
  " added last time in INSERT mode.
  " nnoremap gV `[v`]

  " Move vertically by visual line, j and k not skip the fake line if a long line
  " wrap into two lines.
  nnoremap j gj
  nnoremap k gk

  " Quicker window movement
  nnoremap <C-j> <C-w>j
  nnoremap <C-k> <C-w>k
  nnoremap <C-h> <C-w>h
  nnoremap <C-l> <C-w>l
  " nnoremap <C-;> :tabnext<CR>
  " nnoremap <C-'> :tabprevious<CR>

  " Alt + [h,j,k,l] to resize split window
  if bufwinnr(1)
    " nnoremap ˙ <C-w><
    " nnoremap ∆ <C-w>-
    " nnoremap ˚ <C-w>+
    " nnoremap ¬ <C-w>>
  endif

  " Yank from the cursor to the end of the line, to be consistent with C and D.
  nnoremap Y y$

  " Shortcuts
  " Change Working Directory to that of the current file
  cmap cwd lcd %:p:h
  cmap cd. lcd %:p:h

  " Easier horizontal scrolling
  map zl zL
  map zh zH

  " Visual shifting (Move text left and right without exiting Visual mode)
  vnoremap < <gv
  vnoremap > >gv

  " Insert mode
  inoremap <C-e> <Esc>A
  inoremap <C-a> <Esc>I
  inoremap jj <ESC>
" }

" Leader Shortcuts {
  let mapleader=" "
  nnoremap <leader>l :call ToggleNumber()<CR>
  nnoremap <leader>/ :noh<CR>

  " Search with Ag
  nnoremap <leader>a :Ag!<Space>
  nnoremap <leader>A :Ag!<Space><C-R><C-W><CR>
  " :cw<CR>

  " Code folding options
  nmap <leader>f0 :set foldlevel=0<CR>
  nmap <leader>f1 :set foldlevel=1<CR>
  nmap <leader>f2 :set foldlevel=2<CR>
  nmap <leader>f3 :set foldlevel=3<CR>
  nmap <leader>f4 :set foldlevel=4<CR>
  nmap <leader>f5 :set foldlevel=5<CR>
  nmap <leader>f6 :set foldlevel=6<CR>
  nmap <leader>f7 :set foldlevel=7<CR>
  nmap <leader>f8 :set foldlevel=8<CR>
  nmap <leader>f9 :set foldlevel=9<CR>

  " Edit file in the same directories as the current file
  cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<cr>
  map <leader>ew :e %%
  map <leader>es :sp %%
  map <leader>ev :vsp %%
  map <leader>et :tabe %%

  " Go to window by number
  let i = 1
  while i <= 9
    execute 'nnoremap <Leader>' . i . ' :' . i . 'wincmd w<CR>'
    let i = i + 1
  endwhile

  noremap <leader>. :tabnext<CR>
  noremap <leader>, :tabprevious<CR>

  " Map <Leader>ff to display all lines with keyword under cursor and ask which one to jump to
  nmap <Leader>ff [I:let nr = input("Which one: ")<Bar>exe "normal " . nr ."[\t"<CR>

  " Switch between the last two files
  nnoremap <leader><leader> <c-^>
" }

" UI {
  " Eliminating delays on ESC in VIM.
  set timeoutlen=1000 ttimeoutlen=0

  set number
  set numberwidth=5
  set ruler         " show the cursor position all the time
  set cursorline    " Highlight the screen line of the cursor with CursorLine.

  set laststatus=2  " Always display the status line
  set showcmd       " Show (partial) command in the last line of the screen.  Set this option off if your terminal is slow.
  set wildmenu      " Visual autocomplete for command menu.
  set wildmode=list:longest,full " Command <Tab> completion, list matches, then longest common part, then all.

  set showmatch     " When a bracket is inserted, briefly jump to the matching one.
  set lazyredraw    " Redraw only when need to.

  set backspace=2   " Backspace deletes like most programs in insert mode
  set history=100   " Store history, default is 20
  set autowrite     " Automatically :write before running commands

  set textwidth=80  " Make it obvious where 80 characters is
  set colorcolumn=+1

  set whichwrap=b,s,h,l,<,> " Allow specified keys that move the cursor left/right to move to the
                            " previous/next line when the cursor is on the first/last character in
                            " the line.
  set list listchars=tab:»·,trail:·,nbsp:·  " display extra whitespace.
  set scrolloff=3   " Minimal number of screen lines to keep above and below the cursor.

  " Searching
  set ignorecase      " ignore case when searching
  set smartcase       " Override the 'ignorecase' option if the search pattern contains upper case characters.
  set incsearch       " search as characters are entered
  set hlsearch        " highlight all matches

  set mouse=v                 " Automatically enable mouse usage
  set mousehide               " Hide the mouse cursor while typing
" }

" Formatting {
  set tabstop=2       " Number of spaces that a <Tab> in the file counts for.
  set softtabstop=2   " Number of spaces that a <Tab> counts for while performing editing operations.
  set shiftwidth=2    " Number of spaces to use for each step of (auto)indent.
  set shiftround      " Round indent to multiple of 'shiftwidth'.  Applies to > and < commands.
  set expandtab       " In Insert mode: Use the appropriate number of spaces to insert a <Tab>.
  set autoindent      " Copy indent from current line when starting a new line
  set nojoinspaces    " Use one space, not two, after punctuation.
  set nowrap          " Do not wrap long lines.
  set splitright      " Puts new vsplit windows to the right of the current
  set splitbelow      " Puts new split windows to the bottom of the current
  filetype plugin indent on
" }

" Folding {
  set foldmethod=indent   " The kind of folding used for the current window.
  set foldnestmax=10      " Sets the maximum nesting of folds 
  set foldenable          " When off, all folds are open.
  set foldlevelstart=10   " Sets 'foldlevel' when starting to edit another buffer in a window.
                          " Useful to always start editing with all folds closed (value zero)
" }

" Spell {
  " Autocomplete with dictionary words when spell check is on
  set dictionary+=/usr/share/dict/words
  set complete+=kspell
" }

" Custom Functions {
  function! ToggleNumber()
    if(&relativenumber == 1)
      set norelativenumber
      set number
    else
      set relativenumber
    endif
  endfunc
" }

" Turn backup off, since most stuff is in SVN, git etc {
  set nobackup
  set nowritebackup
  set noswapfile
" }

" When editing a file, always jump to the last known cursor position {
  augroup vimrcEx
    autocmd!

    " Don't do it for commit messages, when the position is invalid, or when
    " inside an event handler (happens when dropping a file on gvim).
    autocmd BufReadPost *
      \ if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |
      \   exe "normal g`\"" |
      \ endif

    " Set syntax highlighting for specific file types
    autocmd BufRead,BufNewFile Appraisals set filetype=ruby
    autocmd BufRead,BufNewFile *.md set filetype=markdown
    autocmd BufRead,BufNewFile .{jscs,jshint,eslint}rc set filetype=json
  augroup END
" }

" When the type of shell script is /bin/sh, assume a POSIX-compatible
" shell for syntax highlighting purposes {
  let g:is_posix = 1
" }

" Tab completion {
  " will insert tab at beginning of line,
  " will use completion if not at beginning
  function! InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
      return "\<tab>"
    else
      return "\<c-p>"
    endif
  endfunction
  inoremap <Tab> <c-r>=InsertTabWrapper()<cr>
  inoremap <S-Tab> <c-n>
" }

" Plugin Config {
  " vim-multiple-cursors {
    " let g:multi_cursor_next_key='<C-n>'
    let g:multi_cursor_exit_from_visual_mode=0
    let g:multi_cursor_exit_from_insert_mode=0
  " }

  " vim-airline {
    let g:airline_powerline_fonts=1
    let g:airline_theme="dark"
  " }

  " NERDTree {
    " map <C-n> :NERDTreeToggle<CR>
    noremap <leader>n :NERDTreeToggle<CR>
    noremap <leader>m :NERDTreeFind<CR>
    " Open NERDTree auto when vim starts up on opening a directly
    autocmd StdinReadPre * let s:std_in=1
    autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
  " }

  " syntastic {
    set statusline+=%#warningmsg#
    set statusline+=%{SyntasticStatuslineFlag()}
    set statusline+=%*

    let g:syntastic_always_populate_loc_list = 1
    " let g:syntastic_auto_loc_list = 1
    let g:syntastic_check_on_open = 0
    let g:syntastic_check_on_wq = 0
    let g:syntastic_ruby_checkers = ['rubocop', 'mri']
    let g:syntastic_javascript_checkers = ['jshint']
  " }

  " NerdCommenter {
    " Add spaces after comment delimiters by default
    let g:NERDSpaceDelims = 1
  " }

  " Ag {
    " Use The Silver Searcher https://github.com/ggreer/the_silver_searcher
    if executable('ag')
      " Use Ag over Grep
      set grepprg=ag\ --nogroup\ --nocolor

      " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
      let g:ctrlp_user_command = 'ag -Q -l --nocolor --hidden -g "" %s'

      " ag is fast enough that CtrlP doesn't need to cache
      let g:ctrlp_use_caching = 0

      if !exists(":Ag")
        command -nargs=+ -complete=file -bar Ag silent! grep! <args>|cwindow|redraw!
        nnoremap \ :Ag<SPACE>
      endif
    endif
  " }

  " fzf {
    let g:fzf_files_options =
      \ '--preview "(coderay {} || cat {}) 2> /dev/null | head -'.&lines.'"'
    nnoremap <C-p> :Files<cr>
    autocmd VimEnter * command! -bang -nargs=* Ag
      \ call fzf#vim#ag(<q-args>,
      \                 <bang>0 ? fzf#vim#with_preview('up:60%')
      \                         : fzf#vim#with_preview('right:50%:hidden', '?'),
      \                 <bang>0)
  " }
" }
