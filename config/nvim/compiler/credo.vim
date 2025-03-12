if exists('current_compiler')
    finish
endif
let current_compiler = 'credo'

if exists(":CompilerSet") != 2
    command -nargs=* CompilerSet setlocal <args>
endif

CompilerSet makeprg=mix\ credo
CompilerSet errorformat=
            \%E┃\ [%.]\ %m,
            \%C┃%.%#\ %f:%l:%c\ %m,
            \%C┃%.%#\ %f:%l\ %m,%Z
