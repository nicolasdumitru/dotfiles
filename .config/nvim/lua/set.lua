-- Line numbering
vim.opt.number = true
vim.opt.relativenumber = true

-- Indentation (number of spaces)
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.cindent = true

-- Search settings (case sensitivity)
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true

-- Colors
vim.opt.termguicolors = true

-- Lines at the top and bottom
vim.opt.scrolloff = 4

-- Update time
vim.opt.updatetime = 50

-- Cursor in the middle of the screen
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
