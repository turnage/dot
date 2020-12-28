with import <nixpkgs> {};

let
  vim = vim_configurable.override { python = python3; };
in
  vim.customize {
    name = "vim";
    vimrcConfig.packages.myVimPackage = with pkgs.vimPlugins; {
      start = [
        YouCompleteMe        
        fugitive
        rust-vim
        tagbar
        syntastic
        vim-go
        vim-glsl
        haskell-vim
        vim-hindent
        goyo-vim
      ];
    };
    vimrcConfig.customRC = ''
      syntax enable
      set expandtab
      set colorcolumn=81
      hi ColorColumn ctermbg=White
      set nu
      set shiftwidth=2
      set softtabstop=2
      set linebreak
      set tw=80
      let g:netrw_banner = 0

      " Haskell 

      filetype plugin indent on
      let g:haskell_enable_quantification = 1   " to enable highlighting of `forall`
      let g:haskell_enable_recursivedo = 1      " to enable highlighting of `mdo` and `rec`
      let g:haskell_enable_arrowsyntax = 1      " to enable highlighting of `proc`
      let g:haskell_enable_pattern_synonyms = 1 " to enable highlighting of `pattern`
      let g:haskell_enable_typeroles = 1        " to enable highlighting of type roles
      let g:haskell_enable_static_pointers = 1  " to enable highlighting of `static`
      let g:haskell_backpack = 1                " to enable highlighting of backpack keywords
      let g:haskell_indent_disable = 1          " use hindent instead

      " Colemak remappings
      noremap m n
      noremap l i
      noremap L I

      noremap n h
      noremap e j
      noremap i k
      noremap o l
      inoremap <BS> <Esc>

      " Syntastic

      set statusline+=%#warningmsg#
      set statusline+=%{SyntasticStatuslineFlag()}
      set statusline+=%*

      let g:syntastic_always_populate_loc_list = 1
      let g:syntastic_auto_loc_list = 1
      let g:syntastic_check_on_open = 1
      let g:syntastic_check_on_wq = 0
      let g:syntastic_quiet_messages = {             
         \ "!level":  "errors",                
         \ "type":    "style"}

      " Rust
      let g:rustfmt_autosave = 1

      " Tagbar

      nnoremap <silent> <F12> :TagbarToggle<CR>
      nnoremap <silent> <F5> :w<CR>
      nnoremap <silent> <F3> :Lex<CR>

      " Explorer

      let g:netrw_banner = 0
      let g:netrw_liststyle = 3
      let g:netrw_browse_split = 4
      let g:netrw_altv = 1
      let g:netrw_winsize = 25
      let g:netrw_list_hide = '\(^\|\s\s\)\zs\.\S\+'

      " YCM

      let g:ycm_autoclose_preview_window_after_insertion = 1
    '';
  }
