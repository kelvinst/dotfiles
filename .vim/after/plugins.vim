filetype off                         " REQUIRED
set rtp+=~/.vim/bundle/Vundle.vim    " REQUIRED
call vundle#begin()                  " REQUIRED
  Plugin 'gmarik/Vundle.vim'         " REQUIRED

  Plugin 'airblade/vim-gitgutter'    " show git changes on a gutter
  Plugin 'YankRing.vim'              " yank history
  Plugin 'chriskempson/base16-vim'   " colorschemes
  Plugin 'easymotion/vim-easymotion' " move around like a pr
  Plugin 'igemnace/vim-makery'       " personalized make commands
  Plugin 'itchyny/lightline.vim'     " status bar improved
  Plugin 'junegunn/fzf'              " quickswitch files
  Plugin 'junegunn/fzf.vim'          " quickswitch files
  Plugin 'kelvinst/vim-elixir'       " elixir support TODO - update to the original
  Plugin 'mattn/emmet-vim'           " generate HTML
  Plugin 'rking/ag.vim'              " fast search in files
  Plugin 'sjl/gundo.vim'             " undo gui
  Plugin 'tpope/vim-abolish'         " for searching and replacing patterns easily
  Plugin 'tpope/vim-apathy'          " set 'path' option for misc file types
  Plugin 'tpope/vim-commentary'      " turn lines into comments
  Plugin 'tpope/vim-dadbod'          " db integration
  Plugin 'tpope/vim-dispatch'        " build and test dispatcher
  Plugin 'tpope/vim-endwise'         " adds end wisely
  Plugin 'tpope/vim-eunuch'          " UNIX useful tasks
  Plugin 'tpope/vim-fugitive'        " git integration
  Plugin 'tpope/vim-haml'            " haml, sass and scss support
  Plugin 'tpope/vim-heroku'          " heroku commands
  Plugin 'tpope/vim-jdaddy'          " heroku commands
  Plugin 'tpope/vim-obsession'       " autosave sessions
  Plugin 'tpope/vim-projectionist'   " project specific config and commands
  Plugin 'tpope/vim-ragtag'          " html helpers
  Plugin 'tpope/vim-repeat'          " repeat mappings
  Plugin 'tpope/vim-rhubarb'         " github integration
  Plugin 'tpope/vim-sensible'        " good defaults
  Plugin 'tpope/vim-sleuth'          " adjusts tabstops configurations
  Plugin 'tpope/vim-speeddating'     " C-A and C-X on dates
  Plugin 'tpope/vim-surround'        " for delimiters changing
  Plugin 'tpope/vim-unimpaired'      " good pair of next-prev and toggles
  Plugin 'tpope/vim-vinegar'         " netrw > NerdTree


call vundle#end()                    " REQUIRED
filetype plugin indent on            " REQUIRED

