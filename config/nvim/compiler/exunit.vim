if exists("current_compiler")
  finish
endif
let current_compiler = "exunit"

if exists(":CompilerSet") != 2    " older Vim always used :setlocal
  command -nargs=* CompilerSet setlocal <args>
endif

let s:cpo_save = &cpo
set cpo-=C
CompilerSet makeprg=mix\ test
CompilerSet errorformat=
  \%E\ \ %n)\ %m,
  \%C\ \ \ \ \ %f:%l,
  \%+G\ \ \ \ \ **\ %m,
  \%+G\ \ \ \ \ stacktrace:,
  \%+G\ \ \ \ \ \ \ (%\\w%\\+)\ %f:%l:\ %m,
  \%+G\ \ \ \ \ \ \ %f:%l:\ %.%#

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: nowrap sw=2 sts=2 ts=8:
