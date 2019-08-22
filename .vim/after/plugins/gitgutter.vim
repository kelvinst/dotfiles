function! s:toggle_gitgutter()
  if g:gitgutter_enabled
    call gitgutter#disable()
    echo ':GitGutterDisable'
  else
    call gitgutter#enable()
    echo ':GitGutterEnable'
  endif
endfunction

let g:gitgutter_enabled = 0
nnoremap [og :GitGutterEnable<cr>
nnoremap ]og :GitGutterDisable<cr>
nnoremap <silent> yog :call <sid>toggle_gitgutter()<cr>

