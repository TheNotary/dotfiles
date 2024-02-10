"set nocompatible              " be iMproved, required
"filetype off                  " required
"
"" set the runtime path to include Vundle and initialize
"set rtp+=~/.vim/bundle/Vundle.vim
"call vundle#begin()
"" Plugin 'VundleVim/Vundle.vim' " I made it not be a git repo for my version
"" control purposes
""Plugin 'godlygeek/tabular'
""Plugin 'plasticboy/vim-markdown'
"
"" All of your Plugins must be added before the following line
"call vundle#end()            " required
"filetype plugin indent on    " required





color desert

syntax on
set autoindent
set expandtab
set tabstop=2
set shiftwidth=2
set backspace=2 " make backspace work like most other apps
" autocmd BufWritePre * %s/\s\+$//e " delete trailing whitespace at ends of lines

execute pathogen#infect()

au BufNewFile,BufRead * if &syntax == '' | set paste | endif

" http://www.vim.org/scripts/script.php?script_id=302
autocmd BufRead,BufNewFile *.log :AnsiEsc
au BufRead,BufNewFile *.handlebars,*.hbs set ft=html syntax=handlebars
au BufRead,BufNewFile *.coffee set ft=js syntax=coffee
au BufRead,BufNewFile *.template set ft=js syntax=json
au BufNewFile,BufRead *.md  setf markdown
au FilterWritePre * if &diff | set wrap | endif
autocmd Filetype python setlocal expandtab tabstop=4 shiftwidth=4

if &diff
  colorscheme autumn
endif

" This is higher contrast than the other garbage, omg
colorscheme biogoo

"""""""""""""""""
"  Plugin List  "
"""""""""""""""""

" git clone https://github.com/plasticboy/vim-markdown.git

" Plugin 'godlygeek/tabular'
" Plugin 'plasticboy/vim-markdown'
