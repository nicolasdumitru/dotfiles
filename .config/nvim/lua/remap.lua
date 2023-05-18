-- These are the remaps (keybindings) that use Neovim's built-in functionality.
-- Remaps that use plugin functionality are set in the "pluginremap.lua" file.

vim.g.mapleader = " "
-- Show Netrw
vim.keymap.set("n", "<leader>lf", vim.cmd.Ex)

-- Update current working directory
vim.keymap.set("n", "<leader>cd", ":cd %:p:h <CR>")

-- Open an external terminal in the current working directory
vim.keymap.set("n", "<leader>tt", ":cd %:p:h <CR> :!$TERM & disown <CR> :mode <CR>")

-- Keep cursor in the middle of the screen
-- when scrolling half a page
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
-- when viewing search results
vim.keymap.set("n", "n", "nzz") -- or "nzzzv"
vim.keymap.set("n", "N", "Nzz") -- or "Nzzzv"

-- Keep the copied string in register when pasting over a highlight
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Easily yank (copy) stuff into the system clipoboard
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Easily delete (cut) stuff into the system clipoboard
vim.keymap.set({"n", "v"}, "<leader>d", [["+d]])
vim.keymap.set("n", "<leader>D", [["+D]])

-- Easily delete stuff without copying it
vim.keymap.set({"n", "v"}, "<leader>c", [["_c]])
vim.keymap.set("n", "<leader>C", [["_C]])
-- Delete stuff without copying it
--vim.keymap.set({"n", "v"}, "<leader>d", [["_d]])

-- Move lines in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Replace a word in the whole file
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- Make the current file (not) executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
vim.keymap.set("n", "<leader>X", "<cmd>!chmod -x %<CR>", { silent = true })
