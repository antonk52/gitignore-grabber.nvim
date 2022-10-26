local M = {}
local function get_gitignores_dir_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    local plugin_lua_dir_path = str:match("(.*/)")
    return vim.fs.normalize(plugin_lua_dir_path .. '../gitignore')
end
local gitignore_submodule_path = get_gitignores_dir_path()
local function get_gitignores_table()
    local result = {}
    local paths = {'', 'community', 'Global'}
    local submodule_path = get_gitignores_dir_path()
    for _, p in ipairs(paths) do
        for name, kind in vim.fs.dir(submodule_path .. '/' .. p) do
            if kind == 'file' and vim.endswith(name, '.gitignore') then
                table.insert(result, p..(p == '' and '' or '/')..name);
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
    local has_telescope = pcall(function() require('telescope') end)
    local has_fzf = vim.fn.exists('*fzf#run')
    if has_telescope then
        require('telescope.pickers').new({}, {
            prompt_title = "Gitignore",
            finder = require('telescope.finders').new_table {
                results = COMPLETION_LIST
            },
            sorter = require("telescope.config").values.generic_sorter({}),
            attach_mappings = function(prompt_bufnr)
                require('telescope.actions').select_default:replace(function()
                    local selection = require('telescope.actions.state').get_selected_entry()
                    insert_gitignore(selection[1]);

                    require('telescope.actions').close(prompt_bufnr)
                end)

                return true
            end,
        }):find()
    elseif has_fzf == 1 then
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

function M.main(param)
    if param == nil or param == '' then
        pick_and_place()
    else
        insert_gitignore(param)
    end
end

function M.autosuggest(arg_lead)
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

return M
