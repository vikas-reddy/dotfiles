" Vikas Reddy vimrc/exrc
"
"
"

" Vi compatibility
set nocompatible

" Jump to the last position
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g'\"" | endif
endif

" Set background as dark. Other options: light
set background=dark

" Turn on Syntax Highlighting
syntax on

" Incremental Search, Highlight Search
set incsearch
set hlsearch

" Smart Case while searching
set smartcase

" Status line @ bottom
set laststatus=1

" Show matching braces
set showmatch

" Terminal title
set title

" Visual beep
" set visualbell

" No error bells
set noerrorbells

" Paste toggle
set pastetoggle=<F2>

" Smart Indenting on
"set smartindent

" Filetype Indenting on
filetype indent on

" The amount to block indent when using < and >
set shiftwidth=2

" <TAB> is 4 spaces
set tabstop=2

" Expand <TAB> to spaces
set expandtab

" Uses shiftwidth instead of tabstop at start of lines
"set smarttab

" Indent whole file in command mode
" gg=G



" Compile from the Vim itself
" set makeprg=gcc\ filename.c
" :make
" Go to next error :cn
" Go to prev error :cN

" Split window horizontally
" split new OR split filename.c

" Split window vertically
" vsplit new OR vsplit filename.c


" Create backup (filename~) files in a given directory
set nobackup

" Custom commands
command -range Comment <line1>,<line2>s/^./#&/
command -range Uncomment <line1>,<line2>s/^#//

" vividchalk colorscheme
colorscheme vividchalk
