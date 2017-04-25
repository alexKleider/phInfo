set autoindent
set shiftwidth=4
set expandtab
set tabstop=4
set softtabstop=4
set textwidth=70
set scrolljump=2
set scrolloff=2
set complete+=kspell
set tags=./mytags
set viminfo='10,\"100,:20,%,n~/.viminfo
set pastetoggle=<F12>
filetype plugin on
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif
