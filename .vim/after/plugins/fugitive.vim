nnoremap <leader>g! :Start gitsh<cr>
nnoremap <leader>g<space> :G<space>
nnoremap <leader>gc :G co<space>
nnoremap <leader>gp :Dispatch git push -u origin `git rev-parse --abbrev-ref HEAD`<cr>
nnoremap <leader>gP :Dispatch git push -u origin `git rev-parse --abbrev-ref HEAD` --force-with-lease<cr>
nnoremap <leader>gr :G rebase<space>
nnoremap <leader>gr<space> :G rebase<space>
nnoremap <leader>grc :G rebase --continue<cr>
nnoremap <leader>grs :G rebase --skip<cr>
nnoremap <leader>gs :G<cr>
nnoremap <leader>gt :tab G<cr>
nnoremap <leader>gu :Dispatch git pull --commit<cr>
noremap <leader>gB :GBrowse!<cr>
noremap <leader>gb :GBrowse<cr>
