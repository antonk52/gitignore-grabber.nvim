local function get_gitignores_dir_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    local plugin_lua_dir_path = str:match("(.*/)")
    return plugin_lua_dir_path .. '../gitignore'
end
local function find_gitignore_paths(path, depth)
    local cmd = 'silent ! find "'..path..'" -depth '..depth..' -type f -name "*.gitignore"'
    return vim.fn.split(vim.fn.execute(cmd), '\n')
end
local gitignore_submodule_path = get_gitignores_dir_path()
local function get_gitignores_table()
    local result = {}

    -- for some reason a single call returns at most 12* items,
    -- but there are ~200 available, so breaking into several calls
    local all_paths = {
        common = find_gitignore_paths(gitignore_submodule_path, 1),
        global1 = find_gitignore_paths(gitignore_submodule_path..'/Global', 1),
        global2 = find_gitignore_paths(gitignore_submodule_path..'/Global', 2),
        global3 = find_gitignore_paths(gitignore_submodule_path..'/Global', 3),
        community1 = find_gitignore_paths(gitignore_submodule_path..'/community', 1),
        community2 = find_gitignore_paths(gitignore_submodule_path..'/community', 2),
        community3 = find_gitignore_paths(gitignore_submodule_path..'/community', 3),
    }

    for _,t in pairs(all_paths) do
        for _,v in pairs(t) do
            if vim.endswith(v, '.gitignore') == true then
                -- we know that the path to gitignore submodule will be relative
                local split = vim.fn.split(v, '../gitignore/')
                for index,filepath in ipairs(split) do
                    if index == 2 then
                        table.insert(result, filepath)
                    end
                end
            end
        end
    end

    return result
end
local COMPLETION_LIST = get_gitignores_table()

local function refresh_directory_buffer(ft)
    if ft == 'dirvish' then
        vim.fn.execute('norm R')
    elseif ft == 'netrw' then
        -- has to be called twice since `r` also reverses the order
        vim.fn.execute('norm r')
        vim.fn.execute('norm r')
    elseif ft == 'nerdtree' then
        vim.fn.execute('norm r')
    else
        print('GitignoreGrabber: Unknown filetype "'..ft..'"')
    end
end

local function is_directory_filetype(ft)
    return ft == 'Nerdtree' or ft == 'dirvish' or ft == 'netrw'
end

local function insert_gitignore(choice)
    local original_filepath = gitignore_submodule_path .. '/' .. choice

    if vim.fn.filereadable(original_filepath) then
        local content = vim.fn.readfile(original_filepath)
        local filetype = vim.bo.filetype
        local filename = vim.fn.expand('%:t')

        if is_directory_filetype(filetype) == true then
            local proposed_filepath = vim.fn.expand('%:p') .. '.gitignore'
            vim.fn.writefile(content, proposed_filepath)

            refresh_directory_buffer(filetype)
        elseif filename == '.gitignore' then
            vim.api.nvim_put(content, '', false, false)
        else
            print('Tried to add "' .. choice .. '" contents to a non .gitignore buffer')
        end
    else
        print('"'..choice..'" is not a valid gitignore file')
    end
end

local function pick_and_place()
    local has_fzf = vim.fn.exists('*fzf#run')
    if has_fzf == 1 then
        local fzf_options = {
            source = COMPLETION_LIST,
            options = {},
        }

        fzf_options["sink*"] = nil
        fzf_options.sink = function(choice)
            insert_gitignore(choice)
        end

        vim.fn["fzf#run"](fzf_options)
    else
        print('GitignoreGrabber: select a .gitignore file. Example ":Gitignore Node.gitignore"')
    end
end

local function main(param)
    if param == nil or param == '' then
        pick_and_place()
    else
        insert_gitignore(param)
    end
end

local function autosuggest(arg_lead)
    if arg_lead == nil or arg_lead == '' then
        return COMPLETION_LIST
    end

    local result = {}

    for _,v in pairs(COMPLETION_LIST) do
        -- we want a case insensitive match
        local pattern = '\\c'..arg_lead
        if vim.fn.match(v, pattern) > -1 then
            table.insert(result, v)
        end
    end

    return result
end

return {
    autosuggest = autosuggest,
    main = main,
}
