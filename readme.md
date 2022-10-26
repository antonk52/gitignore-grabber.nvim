# Gitignore-grabber

A plugin to to copy/populate your .gitignore from [github/gitignore](https://github.com/github/gitignore) project with support for [telescope](https://github.com/nvim-telescope/telescope.nvim) and [fzf](https://github.com/junegunn/fzf).

## Requirements

- Neovim 0.8 or above

## Optional requirements

- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [fzf.vim](https://github.com/junegunn/fzf.vim)

## Install

Using [`vim-plug`](https://github.com/junegunn/vim-plug)

```vim
Plug 'antonk52/gitignore-grabber.nvim'
```

## Usage

There are two primary ways to use this plugin.

1. Open a directory in a buffer and run `:Gitignore <TAB>` to get completion menu of popular gitignore files. If you have `fzf` installed you can run `:Gitignore<CR>` to get fuzzy search autocompletion to pick a gitignore file.
2. Create/open `.gitignore` buffer and run `:Gitignore <TAB>`/`:Gitignore<CR>` to populate the buffer with the picked gitignore's content.
