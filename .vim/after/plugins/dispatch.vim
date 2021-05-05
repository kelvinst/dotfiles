let g:dispatch_quickfix_height = 20

map `<space> :Dispatch<space>
map `<cr> :Dispatch<cr>
map '<space> :Start<space>
map '<cr> :Start<cr>
map ,<space> :0Spawn<space>
map ,<cr> :0Spawn<cr>
map ,! :0Spawn!

function! GetBufferList()
  redir =>buflist
  silent! ls!
  redir END
  return buflist
endfunction

function! ToggleList()
  let buflist = GetBufferList()

  for bufnum in map(filter(split(buflist, '\n'), 'v:val =~ "Quickfix List"'), 'str2nr(matchstr(v:val, "\\d\\+"))')
    if bufwinnr(bufnum) != -1
      exec('cclose')
      return
    endif
  endfor

  let winnr = winnr()
  exec('Copen')

  if winnr() != winnr
    wincmd p
  endif
endfunction

map [oq :Copen<cr>
map ]oq :cclose<cr>
map yoq :call ToggleList()<cr>

" mix tasks
map <leader>mc :Dispatch mix compile<cr>
map <leader>mC :Dispatch mix compile --force<cr>
map <leader>mf :Dispatch mix format<cr>
map <leader>mi :Dispatch iex -S mix<cr>
