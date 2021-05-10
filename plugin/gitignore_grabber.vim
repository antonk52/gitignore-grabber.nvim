fun! Setup()
    if !has('nvim-0.5')
        echohl WarningMsg
        echom "vim-gitignore-grabber won't work outside neovim lower than 0.5"
        echohl None
    endif
endfun

au VimEnter * call Setup()

com! -complete=customlist,gitignore_grabber#autocomplete -nargs=? Gitignore lua require('gitignore_grabber').main("<args>")
