-- These are the remaps (keybindings) that use Neovim's built-in functionality.
-- Remaps that use plugin functionality are set in the "pluginremap.lua" file.

vim.g.mapleader = " "
-- Show Netrw
vim.keymap.set("n", "<leader>lf", vim.cmd.Ex)

-- Unhighlight search results
vim.keymap.set("n", "<leader>/", ":noh <CR>")

-- Keep cursor in the middle of the screen
-- when scrolling half a page
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
-- when viewing search results
vim.keymap.set("n", "n", "nzz") -- or "nzzzv"
vim.keymap.set("n", "N", "Nzz") -- or "Nzzzv"

-- Keep the copied string in register when pasting over a highlight
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Easily copy stuff into the system clipoboard
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", "\"+Y")

-- Delete stuff without copying it
vim.keymap.set({"n", "v"}, "<leader>d", [["_d]])

-- Move lines in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Replace a word in the whole file
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- Make the current file (not) executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
vim.keymap.set("n", "<leader>X", "<cmd>!chmod -x %<CR>", { silent = true })
