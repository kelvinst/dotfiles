let g:coc_global_extensions = ['coc-json', 'coc-git', 'coc-tsserver', 'coc-elixir', 'coc-html', 
      \ 'coc-css']

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <silent><expr> <S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

nmap <silent> gdd <Plug>(coc-definition)
nmap <silent> gdt :call CocActionAsync('jumpDefinition', 'tab drop')<cr>
nmap <silent> gdv :call CocActionAsync('jumpDefinition', 'vsplit')<cr>
nmap <silent> gds :call CocActionAsync('jumpDefinition', 'split')<cr>
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

nmap <leader>rn <Plug>(coc-rename)

xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>ac  <Plug>(coc-codeaction)

nmap <leader>qf  <Plug>(coc-fix-current)

xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"

nnoremap <silent><nowait><expr> <C-d> coc#float#has_scroll() ? coc#float#scroll(1, 4) : "\<C-d>"
nnoremap <silent><nowait><expr> <C-u> coc#float#has_scroll() ? coc#float#scroll(0, 4) : "\<C-u>"
inoremap <silent><nowait><expr> <C-d> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1, 4)\<cr>" : "\<Right>"
inoremap <silent><nowait><expr> <C-u> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0, 4)\<cr>" : "\<Left>"
vnoremap <silent><nowait><expr> <C-d> coc#float#has_scroll() ? coc#float#scroll(1, 4) : "\<C-d>"
vnoremap <silent><nowait><expr> <C-u> coc#float#has_scroll() ? coc#float#scroll(0, 4) : "\<C-u>"

nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

command! -nargs=0 Format :call CocAction('format')
command! -nargs=? Fold :call     CocAction('fold', <f-args>)
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

nnoremap <silent><nowait> <leader>cl  :<C-u>CocList<cr>
nnoremap <silent><nowait> <leader>cl<cr>  :<C-u>CocList<cr>
nnoremap <silent><nowait> <leader>cld  :<C-u>CocList diagnostics<cr>
nnoremap <silent><nowait> <leader>cle  :<C-u>CocList extensions<cr>
nnoremap <silent><nowait> <leader>clg  :<C-u>CocList gstatus<cr>
nnoremap <silent><nowait> <leader>clc  :<C-u>CocList commands<cr>
nnoremap <silent><nowait> <leader>clo  :<C-u>CocList outline<cr>
nnoremap <silent><nowait> <leader>cls  :<C-u>CocList -I symbols<cr>
nnoremap <silent><nowait> <leader>clj  :<C-u>CocNext<CR>
nnoremap <silent><nowait> <leader>clk :<C-u>CocPrev<CR>
nnoremap <silent><nowait> <leader>clp  :<C-u>CocListResume<CR>
nnoremap <silent><nowait> <leader>ci  :<C-u>CocInfo<CR>
nnoremap <silent><nowait> <leader>c,  :<C-u>vs ~/Developer/secret_dotfiles/dotfiles/.vim/coc-settings.json<CR>
