let g:projectionist_heuristics = {
                  \ "&mix.exs":
                  \   {
                  \     'apps/*/mix.exs': { 'type': 'app' },
                  \     'lib/*.ex': {
                  \       'type': 'lib',
                  \       'alternate': 'test/{}_test.exs',
                  \       'template': [
                  \         'defmodule {camelcase|capitalize|dot} do',
                  \         'end'
                  \       ],
                  \     },
                  \     'test/*_test.exs': {
                  \       'type': 'test',
                  \       'alternate': 'lib/{}.ex',
                  \       'dispatch': "mix test test/{}_test.exs`=v:lnum ? ':'.v:lnum : ''`",
                  \       'template': [
                  \         'defmodule {camelcase|capitalize|dot}Test do',
                  \         '  use ExUnit.Case',
                  \         'end'
                  \       ],
                  \     },
                  \     'mix.exs': { 'type': 'mix' },
                  \     'config/*.exs': { 'type': 'config' },
                  \     '*.ex': {
                  \       'makery': {
                  \         'lint': { 'compiler': 'credo' },
                  \         'test': { 'compiler': 'exunit' },
                  \         'build': { 'compiler': 'mix' }
                  \       }
                  \     },
                  \     '*.exs': {
                  \       'makery': {
                  \         'lint': { 'compiler': 'credo' },
                  \         'test': { 'compiler': 'exunit' },
                  \         'build': { 'compiler': 'mix' }
                  \       }
                  \     }
                  \   }
                  \ }
