map <leader>t :FZF<cr>
let g:fzf_command_prefix = 'Z'
let g:fzf_buffers_jump = 1
let $FZF_DEFAULT_COMMAND = 'ag --hidden '.
      \ '--ignore .git '.
      \ '--ignore _build '.
      \ '--ignore deps '.
      \ '--ignore node_modules '.
      \ '-l -g ""'

