let g:lightline = {
    \   'tab_component_function': {
    \     'pwdname': "PwdName",
    \   },
    \   'component_function': {
    \     'filename': 'LightlineFilename',
    \   },
    \   'tabline': {
    \     'right': [[]]
    \   },
    \   'tab': {
    \     'active': ['tabnum', 'pwdname', 'modified'],
    \     'inactive': ['tabnum', 'pwdname', 'modified'],
    \   },
    \ }

function! PwdName(n)
  let pwd = getcwd(tabpagewinnr(a:n), a:n)
  return get(split(pwd, '/'), -1, '')
endfunction

function! LightlineFilename()
  return expand('%') !=# '' ? expand('%') : '[No Name]'
endfunction
