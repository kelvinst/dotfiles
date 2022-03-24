noremap <leader>gb :Gbrowse<cr>
noremap <leader>gB :Gbrowse!<cr>
nnoremap <leader>gs :G<cr>
nnoremap <leader>gu :Dispatch git pull --commit<cr>
nnoremap <leader>gp :Dispatch git push -u origin `git rev-parse --abbrev-ref HEAD`<cr>
nnoremap <leader>gP :Dispatch git push -fu origin `git rev-parse --abbrev-ref HEAD`<cr>
nnoremap <leader>gr :G rebase<space>
nnoremap <leader>gr<space> :G rebase<space>
nnoremap <leader>grc :G rebase --continue<cr>
nnoremap <leader>grs :G rebase --skip<cr>
nnoremap <leader>gS :Start gitsh<cr>
nnoremap <leader>gc :G co<space>
nnoremap <leader>gs :G<cr>
nnoremap <leader>g<space> :G<space>
