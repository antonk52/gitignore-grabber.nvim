function! gitignore_grabber#autocomplete(arg_lead, cmd_line, cursor_pos)
    echom '1 gitignore_grabber#autocomplete params a: '.a:arg_lead.', b: '.a:cmd_line.', c: '.a:cursor_pos

    lua X = require('gitignore_grabber').autosuggest(vim.fn.eval('a:arg_lead'))

    return luaeval("X")
endfunction
