-- Config for lua-language-server.
-- Merged by Neovim (>= 0.11) into the base `lua_ls` config from nvim-lspconfig.
--
-- Without this, editing this very config produced ~30 bogus
-- "Undefined global `vim`" diagnostics per file.
return {
	settings = {
		Lua = {
			runtime = {
				-- Neovim uses LuaJIT, which is 5.1-compatible.
				version = "LuaJIT",
			},
			diagnostics = {
				-- Teach the server about Neovim's injected globals.
				globals = { "vim", "Snacks" },
			},
			workspace = {
				-- Make the server aware of the Neovim runtime files so that
				-- `vim.api.*`, `vim.fn.*` etc. get completion and signature help.
				library = vim.api.nvim_get_runtime_file("lua", true),
				checkThirdParty = false,
			},
			-- Don't send telemetry to the lua-language-server authors.
			telemetry = { enable = false },
			format = {
				-- stylua handles formatting (see plugins/formatting.lua).
				enable = false,
			},
		},
	},
}
