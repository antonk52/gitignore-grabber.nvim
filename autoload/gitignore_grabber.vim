function! gitignore_grabber#autocomplete(arg_lead, cmd_line, cursor_pos)
    lua X = require('gitignore_grabber').autosuggest(vim.fn.eval('a:arg_lead'))

    return luaeval("X")
endfunction
