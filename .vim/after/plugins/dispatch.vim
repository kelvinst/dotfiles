let g:dispatch_quickfix_height = 20

map `<space> :Dispatch<space>
map `<cr> :Dispatch<cr>
map '<space> :Start<space>
map '<cr> :Start<cr>
map ,<space> :0Spawn<space>
map ,<cr> :0Spawn<cr>
map ,! :0Spawn!

" mix tasks
nmap <leader>mc :Dispatch mix compile<cr>
nmap <leader>mC :Dispatch mix compile --force<cr>
nmap <leader>mf :Dispatch mix format<cr>
nmap <leader>mi :Dispatch iex -S mix<cr>
