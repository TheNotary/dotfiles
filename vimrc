color desert

syntax on
set autoindent
set expandtab
set tabstop=2
set shiftwidth=2

execute pathogen#infect()

au BufNewFile,BufRead * if &syntax == '' | set paste | endif

au FilterWritePre * if &diff | set wrap | endif

if &diff
  colorscheme autumn
endif


