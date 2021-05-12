function! s:incsearch_config(...) abort
  return incsearch#util#deepextend(deepcopy({
  \   'modules': [incsearch#config#easymotion#module({'overwin': 1})],
  \   'keymap': {
  \     "\<CR>": '<Over>(easymotion)'
  \   },
  \   'is_expr': 0
  \ }), get(a:, 1, {}))
endfunction

function! s:config_easyfuzzymotion(...) abort
  return extend(copy({
  \   'converters': [incsearch#config#fuzzyword#converter()],
  \   'modules': [incsearch#config#easymotion#module({'overwin': 1})],
  \   'keymap': {"\<CR>": '<Over>(easymotion)'},
  \   'is_expr': 0,
  \   'is_stay': 1
  \ }), get(a:, 1, {}))
endfunction

nmap s <Plug>(easymotion-overwin-f)
map <space> <Plug>(easymotion-prefix)
map <space>S <Plug>(easymotion-s2)
noremap <silent><expr> /  incsearch#go(<SID>incsearch_config())
noremap <silent><expr> ?  incsearch#go(<SID>incsearch_config({'command': '?'}))
noremap <silent><expr> g/ incsearch#go(<SID>incsearch_config({'is_stay': 1}))
noremap <silent><expr> <space>/ incsearch#go(<SID>config_easyfuzzymotion())
map <space>G <Plug>(easymotion-bd-jk)
map <space>l <Plug>(easymotion-lineforward)
map <space>h <Plug>(easymotion-linebackward)
map <space><space> <Plug>(easymotion-bd-w)

let g:EasyMotion_startofline = 0 " keep cursor column when JK motion

