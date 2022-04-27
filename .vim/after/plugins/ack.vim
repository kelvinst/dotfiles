let g:ackprg = 'ag --vimgrep '.
      \ '--hidden '.
      \ '--ignore .git '.
      \ '--ignore _build '.
      \ '--ignore deps '.
      \ '--ignore node_modules '.
      \ '-l -g ""'
