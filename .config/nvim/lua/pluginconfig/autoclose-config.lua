-- Autoclose plugin
require("autoclose").setup({
	options = {
		disabled_filetypes = { "TelescopePrompt" },
		disable_when_touch = true,
	},
	keys = {
      ["\\\""] = { escape = false, close = false },
   },
})
