filetype off                                               " REQUIRED
set rtp+=~/.vim/bundle/Vundle.vim                          " REQUIRED
call vundle#begin()                                        " REQUIRED
  Plugin 'gmarik/Vundle.vim'                               " REQUIRED

  Plugin 'YankRing.vim'                                    " yank history
  Plugin 'airblade/vim-gitgutter'                          " show git changes on a gutter
  Plugin 'chriskempson/base16-vim'                         " colorschemes
  Plugin 'TaDaa/vimade'                                    " fade inactive windows
  Plugin 'christoomey/vim-tmux-navigator'                  " seamless vim <> tmux navigation
  Plugin 'ciaranm/detectindent'                            " inteligently set <tab> config
  Plugin 'easymotion/vim-easymotion'                       " move around like a pr
  Plugin 'haya14busa/incsearch.vim'                        " incremental search
  Plugin 'haya14busa/incsearch-fuzzy.vim'                  " fuzzy incremental search
  Plugin 'haya14busa/incsearch-easymotion.vim'             " easymotion incremental search
  Plugin 'igemnace/vim-makery'                             " personalized make commands
  Plugin 'itchyny/lightline.vim'                           " status bar improved
  Plugin 'junegunn/fzf'                                    " quickswitch files support
  Plugin 'junegunn/fzf.vim'                                " quickswitch files
  Plugin 'junegunn/vim-easy-align'                         " aligning
  Plugin 'elixir-editors/vim-elixir'                       " elixir support
  Plugin 'mattn/emmet-vim'                                 " generate HTML
  Plugin 'mbbill/undotree'                                 " undo gui
  Plugin 'neoclide/coc.nvim', {'branch': 'release'}        " conquer of completion
  Plugin 'PhilRunninger/nerdtree-visual-selection'         " allow multiple files on NERDTree
  Plugin 'preservim/nerdtree'                              " a better file tree view
  Plugin 'rking/ag.vim'                                    " fast search in files
  Plugin 'tmux-plugins/vim-tmux-focus-events'              " Focus events from tmux
  Plugin 'tpope/vim-abolish'                               " better searching/replacing patterns
  Plugin 'tpope/vim-apathy'                                " set 'path' option for misc file types
  Plugin 'tpope/vim-commentary'                            " turn lines into comments
  Plugin 'tpope/vim-dadbod'                                " db integration
  Plugin 'tpope/vim-dispatch'                              " build and test dispatcher
  Plugin 'tpope/vim-eunuch'                                " UNIX useful tasks
  Plugin 'tpope/vim-fugitive'                              " git integration
  Plugin 'tpope/vim-haml'                                  " haml, sass and scss support
  Plugin 'tpope/vim-heroku'                                " heroku commands
  Plugin 'tpope/vim-jdaddy'                                " JSON manipulation and printing
  Plugin 'tpope/vim-obsession'                             " autosave sessions
  Plugin 'tpope/vim-projectionist'                         " project specific config and commands
  Plugin 'tpope/vim-ragtag'                                " html helpers
  Plugin 'tpope/vim-repeat'                                " repeat mappings
  Plugin 'tpope/vim-rhubarb'                               " github integration
  Plugin 'tpope/vim-sensible'                              " good defaults
  Plugin 'tpope/vim-sleuth'                                " adjusts tabstops configurations
  Plugin 'tpope/vim-speeddating'                           " C-A and C-X on dates
  Plugin 'tpope/vim-surround'                              " for delimiters changing
  Plugin 'tpope/vim-unimpaired'                            " good pair of next-prev and toggles


call vundle#end()                                          " REQUIRED
filetype plugin indent on                                  " REQUIRED

