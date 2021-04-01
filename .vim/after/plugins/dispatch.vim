let g:dispatch_quickfix_height = 20

map `<space> :Dispatch<space>
map `<cr> :Dispatch<cr>
map '<space> :Start<space>
map '<cr> :Start<cr>

" mix tasks
map <leader>mc :Dispatch mix compile<cr>
map <leader>mC :Dispatch mix compile --force<cr>
map <leader>mf :Dispatch mix force<cr>
