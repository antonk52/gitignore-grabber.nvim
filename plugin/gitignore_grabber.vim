if !has('nvim-0.5')
    echoerr "gitignore-grabber.nvim won't work outside neovim older than 0.5"
    finish
endif

com! -complete=customlist,gitignore_grabber#autocomplete -nargs=? Gitignore lua require('gitignore_grabber').main("<args>")
