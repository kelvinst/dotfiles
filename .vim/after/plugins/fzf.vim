let g:fzf_command_prefix = 'Z'
let g:fzf_buffers_jump = 1
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.7 } }
let $FZF_DEFAULT_COMMAND = 'ag --hidden '.
      \ '--ignore .git '.
      \ '--ignore _build '.
      \ '--ignore boundary '.
      \ '--ignore cover '.
      \ '--ignore deps '.
      \ '--ignore docs '.
      \ '--ignore node_modules '.
      \ '-l -g ""'

nmap <leader>t :ZFiles<cr>

nmap <leader>zf :ZFiles<cr>
nmap <leader>zg :ZGFiles?<cr>
nmap <leader>zgf :ZGFiles<cr>
nmap <leader>zgs :ZGFiles?<cr>
nmap <leader>zgc :ZCommit<cr>
nmap <leader>zgcb :ZBCommits<cr>
nmap <leader>zb :ZBuffer<cr>
nmap <leader>zC :ZColors<cr>
nmap <leader>za<space> :ZAg<space>
nmap <leader>za<cr> :ZAg<cr>
nmap <leader>zr :ZRg<cr>
nmap <leader>zl :ZBLines<cr>
nmap <leader>zt :ZBTags<cr>
nmap <leader>zm :ZMark<cr>
nmap <leader>zw :ZWindows<cr>
nmap <leader>zhf :ZHistory<cr>
nmap <leader>zhc :ZHistory:<cr>
nmap <leader>zhs :ZHistory/<cr>
nmap <leader>zc :ZCommand<cr>
nmap <leader>zm :ZMaps<cr>
nmap <leader><tab> <plug>(fzf-maps-n)
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)
nmap <leader>zh :ZHelptags<cr>
nmap <leader>zft :ZFiletype<cr>
