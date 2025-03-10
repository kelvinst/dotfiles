if exists('current_compiler')
    finish
endif
let current_compiler = 'mix'

if exists(":CompilerSet") != 2
    command -nargs=* CompilerSet setlocal <args>
endif

CompilerSet makeprg=mix\ compile
CompilerSet errorformat=
            \%+W%\\s%#warning:\ %m,
            \%G\ %.%#\ %f:%l:%c:\ %m,
            \%G\ %.%#\ %f:%l:\ %m,%Z,
            \%+E==\ Compilation\ error\ in\ file\ %.%#\ ==,
            \%G%m\ %f:%l:%c%.%#,
            \%G%m\ %f:%l%.%#

