let g:dispatch_quickfix_height = 20

map `<space> :Dispatch<space>
map `<cr> :Dispatch<cr>
map '<space> :Start<space>
map '<cr> :Start<cr>
map ,<space> :0Spawn<space>
map ,<cr> :0Spawn<cr>
map ,! :0Spawn!

" mix tasks
map <leader>mc :Dispatch mix compile<cr>
map <leader>mC :Dispatch mix compile --force<cr>
map <leader>mf :Dispatch mix format<cr>
map <leader>mi :Dispatch iex -S mix<cr>
