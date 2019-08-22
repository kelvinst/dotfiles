let g:lightline = {
    \   'tab_component_function': {
    \     'pwdname': "PwdName",
    \   },
    \   'tabline': {
    \     'right': [[]]
    \   },
    \   'tab': {
    \     'active': ['tabnum', 'pwdname', 'modified'],
    \     'inactive': ['tabnum', 'pwdname', 'modified'],
    \   }
    \ }

function! PwdName(n)
  let pwd = getcwd(tabpagewinnr(a:n), a:n)
  return get(split(pwd, '/'), -1, '')
endfunction

