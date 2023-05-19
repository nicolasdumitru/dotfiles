-- Plugin configuration

-- Lazy plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Lazy plugins
require("lazy").setup({
	{ "ellisonleao/gruvbox.nvim", priority = 1000 },
	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
	{
		"VonHeikemen/lsp-zero.nvim",
		branch = "v2.x",
		dependencies = {
			-- LSP Support
			{"neovim/nvim-lspconfig"},             -- Required
			{                                      -- Optional
				"williamboman/mason.nvim",
				build = function()
				  pcall(vim.cmd, "MasonUpdate")
				end,
			},
			{"williamboman/mason-lspconfig.nvim"}, -- Optional

			-- Autocompletion
			{"hrsh7th/nvim-cmp"},     -- Required
			{"hrsh7th/cmp-nvim-lsp"}, -- Required
			{"L3MON4D3/LuaSnip"},     -- Required
		}
	},
	{
		"nvim-telescope/telescope.nvim", branch = "0.1.x",
			dependencies = { "nvim-lua/plenary.nvim" }
	}
})

-- Gruvbox theme options
-- Setup must be called before loading the colorscheme
require("pluginconfig.gruvbox-options")

-- Set the theme
vim.cmd("colorscheme gruvbox")

-- LSP (LSP Zero)
require("pluginconfig.lsp-zero-config")

-- Treesitter setup
require("pluginconfig.treesitter-setup")

-- Remaps that use plugin functionality
require("pluginconfig.pluginremap")
