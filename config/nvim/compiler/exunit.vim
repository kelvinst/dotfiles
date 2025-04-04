if exists("current_compiler")
  finish
endif
let current_compiler = "exunit"

if exists(":CompilerSet") != 2    " older Vim always used :setlocal
  command -nargs=* CompilerSet setlocal <args>
endif

CompilerSet makeprg=mix\ test
CompilerSet makeprg=mix\ coveralls
CompilerSet makeprg=mix\ coveralls\.html
CompilerSet errorformat=
            \%E\ \ %n)\ %m,
            \%C\ \ \ \ \ %f:%l,
            \%G\ %.%#\ (%.%#)\ %f:%l:%c:\ %m,
            \%G\ %.%#\ (%.%#)\ %f:%l:\ %m,
            \%G\ %.%#\ %f:%l:%c:\ %m,
            \%G\ %.%#\ %f:%l:\ %m
