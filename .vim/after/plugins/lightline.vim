let g:lightline = {
    \   'component_function': {
    \     'filename': 'LightlineFilename',
    \   },
    \   'tabline': {
    \     'right': [[]]
    \   },
    \ }

function! LightlineFilename()
  return expand('%') !=# '' ? expand('%') : '[No Name]'
endfunction
