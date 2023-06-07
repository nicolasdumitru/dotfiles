-- LSP (LSP Zero)
local lsp = require("lsp-zero").preset({
	{
		float_border = "rounded",
		call_servers = "local",
		configure_diagnostics = true,
		setup_servers_on_start = true,
		set_lsp_keymaps = {
			preserve_mappings = false,
			omit = {},
		},
		manage_nvim_cmp = {
			set_sources = "recommended",
			set_basic_mappings = true,
			set_extra_mappings = false,
			use_luasnip = true,
			set_format = true,
			documentation_window = true,
		},
	}
})

lsp.on_attach(function(client, bufnr)
	lsp.default_keymaps({buffer = bufnr})
end)

lsp.ensure_installed({
	"clangd",
	"rust_analyzer",
	"lua_ls",
})

require("lspconfig").lua_ls.setup(lsp.nvim_lua_ls())

lsp.setup()

-- nvim-cmp configuration
-- Make sure you setup `cmp` after lsp-zero
local cmp = require("cmp")
local cmp_action = require("lsp-zero").cmp_action()

cmp.setup({
	preselect = "item",
	completion = {
		completeopt = "menu,menuone,noinsert"
	},
	sources = {
		{name = "nvim_lsp"},
		{name = "luasnip"},
	},
	mapping = {
		["<CR>"] = cmp.mapping.confirm({select = true}),
		["<Tab>"] = cmp_action.tab_complete(),
		["<S-Tab>"] = cmp_action.select_prev_or_fallback(),
	},
})
