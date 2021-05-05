noremap <leader>gb :Gbrowse<cr>
noremap <leader>gB :Gbrowse!<cr>
nnoremap <leader>gu :Dispatch git pull --commit<cr>
nnoremap <leader>gp :Dispatch git push -u origin `git rev-parse --abbrev-ref HEAD`<cr>
nnoremap <leader>gP :Dispatch git push -fu origin `git rev-parse --abbrev-ref HEAD`<cr>
nnoremap <leader>gr :Dispatch git pull --commit && git push -u origin `git rev-parse --abbrev-ref HEAD`<cr>
nnoremap <leader>gR :Dispatch git pull --commit && git push -fu origin `git rev-parse --abbrev-ref HEAD`<cr>
nnoremap <leader>gS :Dispatch gitsh<cr>
nnoremap <leader>gc :G co<space>
nnoremap <leader>g<space> :G<space>
