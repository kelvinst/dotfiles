noremap <leader>gb :Gbrowse<cr>
noremap <leader>gB :Gbrowse!<cr>
nnoremap <leader>gs :vertical Gstatus<cr>
nnoremap <leader>gp :Dispatch git push -u origin `git rev-parse --abbrev-ref HEAD`<cr>
nnoremap <leader>gP :Dispatch git push -fu origin `git rev-parse --abbrev-ref HEAD`<cr>
nnoremap <leader>gu :Gpull<cr>
nnoremap <leader>gc :G co<space>
nnoremap <leader>g<space> :G<space>
