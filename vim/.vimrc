



" Get the resolved path of the symlinked .vimrc
let s:rcfile = resolve(expand('<sfile>:p'))

" Get the directory of the resolved .vimrc file
let s:rcdir = fnamemodify(s:rcfile, ':h')




" Settings only applicable to VIM
" =========================================
if !has("nvim")
" source <sfile>:h/vim.vim
" source vim.vim
" execute 'source' s:rcdir/ . '/vim.vim'
" execute 'source' fnamemodify(s:rcfile, ':h') . '/vim.vim'
" execute 'source' fnamemodify(s:rcfile, ':h')
execute 'source' s:rcdir . '/' . 'vim.vim'
execute 'source' s:rcdir . '/' . 'keybindings.vim'
endif " End of the Only VIM Related Settings




" Setting only applicable to NVIM
" =========================================
if has("nvim")
  " source <sfile>:h/nvim.vim
  " source nvim.vim
  execute 'source' s:rcdir . '/' . 'nvim.vim'
endif




" Setting only applicable to both VIM/NVIM
" =========================================
  " source <sfile>:h/common.vim
  " source <sfile>:h/mappings.vim
  " source <sfile>:h/options.vim
  " source <sfile>:h/autocommands.vim
execute 'source' s:rcdir . '/' . 'common.vim'
execute 'source' s:rcdir . '/' . 'mappings.vim'
execute 'source' s:rcdir . '/' . 'options.vim'
execute 'source' s:rcdir . '/' . 'autocommands.vim'





" Local config -- For addtional settings.
" =========================================
if filereadable($HOME . "/.vimrc.local")
  source ~/.vimrc.local
endif
