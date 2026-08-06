-- lua-language-server. Merged by Neovim (>= 0.11) into nvim-lspconfig's base
-- config. Without it, editing this config reports every `vim` as undefined.
return {
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			diagnostics = {
				-- Globals Neovim injects.
				globals = { "vim", "Snacks" },
			},
			workspace = {
				-- Neovim runtime files, for completion on vim.api.* / vim.fn.*
				library = vim.api.nvim_get_runtime_file("lua", true),
				checkThirdParty = false,
			},
			telemetry = { enable = false },
			format = {
				enable = false, -- stylua handles this (plugins/formatting.lua)
			},
		},
	},
}
