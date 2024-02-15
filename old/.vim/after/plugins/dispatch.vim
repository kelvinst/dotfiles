let g:dispatch_quickfix_height = 20

map `<space> :Dispatch<space>
map `<cr> :Dispatch<cr>
map '<space> :Start<space>
map '<cr> :Start<cr>
map ,<space> :0Spawn<space>
map ,<cr> :0Spawn<cr>
map ,! :0Spawn!

" mix tasks
nmap <leader>mcc :Dispatch mix compile<cr>
nmap <leader>mcC :Dispatch mix compile --force<cr>
nmap <leader>mcw :Dispatch mix compile --all-warnings --warnings-as-errors<cr>
nmap <leader>mcW :Dispatch mix compile --all-warnings --warnings-as-errors --force<cr>
nmap <leader>md :Dispatch mix deps.get<cr>
nmap <leader>mf :Dispatch mix format<cr>
nmap <leader>mm :Dispatch mix main<cr>
nmap <leader>mtt :Dispatch mix test<cr>
nmap <leader>mtT :Dispatch mix cmd mix test<cr>
nmap <leader>mtc :Dispatch mix test --cover<cr>
nmap <leader>mtC :Dispatch mix cmd mix test --cover<cr>
nmap <leader>mi :Dispatch iex -S mix<cr>
