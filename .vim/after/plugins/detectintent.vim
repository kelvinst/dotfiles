let detectindent_preferred_expandtab = 1
let detectindent_preferred_indent = 2
let detectindent_preferred_when_mixed = 1

augroup detectindent
      autocmd!
      autocmd BufReadPost * execute 'DetectIndent'
augroup END
