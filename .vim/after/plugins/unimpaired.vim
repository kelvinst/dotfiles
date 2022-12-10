" useful functions
function! GetBufferList()
  redir =>buflist
  silent! ls!
  redir END
  return buflist
endfunction

function! CloseBuffer(bufname)
  let buflist = GetBufferList()

  for bufnum in map(filter(split(buflist, '\n'), 'v:val =~ "'.a:bufname.'"'), 'str2nr(matchstr(v:val, "\\d\\+"))')
    if bufwinnr(bufnum) != -1
      exec('bd '.bufnum)
      return
    endif
  endfor
endfunction

function! ToggleBuffer(bufname, oncmd)
  let buflist = GetBufferList()

  for bufnum in map(filter(split(buflist, '\n'), 'v:val =~ "'.a:bufname.'"'), 'str2nr(matchstr(v:val, "\\d\\+"))')
    if bufwinnr(bufnum) != -1
      exec('bd '.bufnum)
      return
    endif
  endfor

  exec(a:oncmd)
endfunction

" dispatch
nnoremap [oq :Copen<cr>
nnoremap ]oq :cclose<cr>
nnoremap yoq :call ToggleBuffer("Quickfix List", 'Copen')<cr>

" gitgutter
nnoremap [oD :GitGutterEnable<cr>
nnoremap ]oD :GitGutterDisable<cr>
nnoremap yoD :GitGutterToggle<cr>

" nerdtree
nnoremap [ot :NERDTreeMirror<cr>:NERDTree<cr>
nnoremap ]ot :NERDTreeMirror<cr>:NERDTreeClose<cr>
nnoremap yot :NERDTreeMirror<cr>:NERDTreeToggle<cr>

" undotree
nnoremap [ou :UndotreeShow<cr>:UndotreeFocus<cr>
nnoremap ]ou :UndotreeHide<cr>
nnoremap you :UndotreeToggle<cr>:UndotreeFocus<cr>

" unimpaired
nnoremap [oz :setlocal cursorcolumn<cr>
nnoremap ]oz :setlocal nocursorcolumn<cr>
nnoremap yoz :setlocal &cursorcolumn ? nocursorcolumn : cursorcolumn<cr>

nnoremap [oo :setlocal readonly<cr>
nnoremap ]oo :setlocal noreadonly<cr>
nnoremap yoo :setlocal &readonly ? noreadonly : readonly<cr>

" vimade
nnoremap [of :VimadeEnable<cr>
nnoremap ]of :VimadeDisable<cr>
nnoremap yof :VimadeToggle<cr>
