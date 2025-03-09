if exists('current_compiler')
    finish
endif
let current_compiler = 'mix'

if exists(":CompilerSet") != 2
    command -nargs=* CompilerSet setlocal <args>
endif

CompilerSet makeprg=mix\ compile
CompilerSet errorformat=
            \%W%\\s%#warning:\ %m,
            \%C\ %.%#\ %f:%l:%c:\ %m,
            \%+G\ %.%#,%Z,
            \%E==\ Compilation\ error\ in\ file\ %.%#\ ==,
            \%C%m\ %f:%l:%c%.%#,
            \%+G\ %.%#,%Z

