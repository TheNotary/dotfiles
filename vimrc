color desert

syntax on
set autoindent
set tabstop=2
set shiftwidth=2

execute pathogen#infect()

au BufNewFile,BufRead README set paste

au FilterWritePre * if &diff | set wrap | endif

if &diff
  colorscheme autumn
endif


