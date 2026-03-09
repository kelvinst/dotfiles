if exists('current_compiler')
    finish
endif
let current_compiler = 'mix_precommit'

if exists(":CompilerSet") != 2
    command -nargs=* CompilerSet setlocal <args>
endif

CompilerSet makeprg=mix\ precommit
CompilerSet errorformat=
            \%W[%.]\ %.\ %f:%l:%c\ %m,
            \%W[%.]\ %.\ %f:%l\ %m,
            \%E┃\ [%.]\ %m,
            \%C┃%.%#\ %f:%l:%c\ %m,
            \%C┃%.%#\ %f:%l\ %m,%Z,
            \%+W%\\s%#warning:\ %m,
            \%+E==\ Compilation\ error\ in\ file\ %.%#\ ==,
            \%C%.%#\ %f:%l:%c:\ %m,
            \%C%.%#\ %f:%l:\ %m,
            \%C%.%#\ %f:%l:%c%.%#,
            \%C%.%#\ %f:%l%.%#,
            \%C%m\ %f:%l:%c%.%#,
            \%C%m\ %f:%l%.%#,
            \%E\ \ %n)\ %m,
            \%C\ \ \ \ \ %f:%l,
            \%G\ %.%#\ (%.%#)\ %f:%l:%c:\ %m,
            \%G\ %.%#\ (%.%#)\ %f:%l:\ %m,
            \%G\ %.%#\ %f:%l:%c:\ %m,
            \%G\ %.%#\ %f:%l:\ %m,
            \%+C\ %.%#,%Z
