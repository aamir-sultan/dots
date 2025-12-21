vim.lsp.enable({
	"svls",
})

vim.diagnostic.config({
	-- virtual_lines = true,
	virtual_text = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		border = "rounded",
		source = true,
	},
	signs = {
		-- text = {
		-- 	[vim.diagnostic.severity.ERROR] = "󰅚 ",
		-- 	[vim.diagnostic.severity.WARN] = " ",
		-- 	[vim.diagnostic.severity.INFO] = "󰋽 ",
		-- 	[vim.diagnostic.severity.HINT] = "󰌶 ",
		-- },
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.HINT] = "󰠠 ",
			[vim.diagnostic.severity.INFO] = " ",
		},
		numhl = {
			[vim.diagnostic.severity.ERROR] = "ErrorMsg",
			[vim.diagnostic.severity.WARN] = "WarningMsg",
		},
	},
})
