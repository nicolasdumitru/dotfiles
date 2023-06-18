vim.g.lf_netrw = 1

require("lf").setup({
	escape_quit = false,
	border = "rounded",
})

vim.keymap.set("n", "<A-o>", ":Lf<CR>")
