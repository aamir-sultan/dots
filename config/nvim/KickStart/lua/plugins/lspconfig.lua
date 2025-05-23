return {

	{
		"neovim/nvim-lspconfig",
		tag = "v1.8.0",
		-- lazy = true,
		event = { "BufReadPost" },
		-- event = { "BufReadPre" },
		dependencies = {
			-- Automatically install LSPs and related tools to stdpath for Neovim
			-- Mason must be loaded before its dependents so we need to set it up here.
			-- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
			{ "williamboman/mason.nvim", tag = "v1.11.0", opts = {} },
			{ "williamboman/mason-lspconfig.nvim", tag = "v1.31.0" },
			{ "WhoIsSethDaniel/mason-tool-installer.nvim", opts = {} },
			{ "antosha417/nvim-lsp-file-operations", config = true },

			-- Useful status updates for LSP.
			{ "j-hui/fidget.nvim", opts = {} },

			-- Allows extra capabilities provided by nvim-cmp
			"hrsh7th/cmp-nvim-lsp",
		},

		config = function()
			-- import lspconfig plugin
			local lspconfig = require("lspconfig")

			-- import mason_lspconfig plugin
			local mason = require("mason")
			local mason_lspconfig = require("mason-lspconfig")
			local mason_tool_installer = require("mason-tool-installer")

			-- enable mason and configure icons
			mason.setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})

			mason_lspconfig.setup({
				-- list of servers for mason to install
				ensure_installed = {
					-- "tsserver",
					-- "html",
					-- "cssls",
					-- "tailwindcss",
					-- "svelte",
					"lua_ls",
					-- "pyright",
				},
			})

			mason_tool_installer.setup({
				ensure_installed = {
					-- "prettier", -- prettier formatter
					{
						"stylua", -- lua formatter
						version = "v2.0.2",
					},
					-- "isort", -- python formatter
					-- "black", -- python formatter
					-- 'mypy', -- python linter
					-- "pylint",
					-- "eslint_d",
				},
				auto_update = true,
				run_on_start = true,
				start_delay = 3000, -- 3 second delay
			})

			-- Change diagnostic symbols in the sign column (gutter)
			if vim.g.have_nerd_font then
				local signs = { ERROR = "", WARN = "", INFO = "", HINT = "" }
				local diagnostic_signs = {}
				for type, icon in pairs(signs) do
					diagnostic_signs[vim.diagnostic.severity[type]] = icon
				end
				vim.diagnostic.config({ signs = { text = diagnostic_signs } })
			end

			-- import cmp-nvim-lsp plugin
			local cmp_nvim_lsp = require("cmp_nvim_lsp")
			local map = vim.keymap.set -- for conciseness

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					-- Buffer local mappings.
					-- See `:help vim.lsp.*` for documentation on any of the below functions
					local opts = { buffer = ev.buf, silent = true }

					-- set keybinds
					-- opts.desc = "Show LSP references"
					-- map("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references
					--
					-- opts.desc = "Go to declaration"
					-- map("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration
					--
					-- opts.desc = "Show LSP definitions"
					-- map("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions
					--
					-- opts.desc = "Show LSP implementations"
					-- map("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations
					--
					-- opts.desc = "Show LSP type definitions"
					-- map("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

					opts.desc = "See available code actions"
					map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

					opts.desc = "Smart rename"
					map("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

					-- opts.desc = "Show buffer diagnostics"
					-- map("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

					opts.desc = "Show line diagnostics"
					map("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

					opts.desc = "Go to previous diagnostic"
					map("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

					opts.desc = "Go to next diagnostic"
					map("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

					opts.desc = "Show documentation for what is under cursor"
					map("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

					opts.desc = "Restart LSP"
					map("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
				end,
			})

			-- used to enable autocompletion (assign to every lsp server config)
			local capabilities = cmp_nvim_lsp.default_capabilities()

			-- Change the Diagnostic symbols in the sign column (gutter)
			-- (not in youtube nvim video)
			local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
			for type, icon in pairs(signs) do
				local hl = "DiagnosticSign" .. type
				vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
			end

			mason_lspconfig.setup_handlers({
				-- default handler for installed servers
				function(server_name)
					lspconfig[server_name].setup({
						capabilities = capabilities,
					})
				end,

				-- ["svelte"] = function()
				--   -- configure svelte server
				--   lspconfig["svelte"].setup({
				--     capabilities = capabilities,
				--     on_attach = function(client, bufnr)
				--       vim.api.nvim_create_autocmd("BufWritePost", {
				--         pattern = { "*.js", "*.ts" },
				--         callback = function(ctx)
				--           -- Here use ctx.match instead of ctx.file
				--           client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
				--         end,
				--       })
				--     end,
				--   })
				-- end,
				--
				-- ["graphql"] = function()
				--   -- configure graphql language server
				--   lspconfig["graphql"].setup({
				--     capabilities = capabilities,
				--     filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
				--   })
				-- end,
				--
				-- ["emmet_ls"] = function()
				--   -- configure emmet language server
				--   lspconfig["emmet_ls"].setup({
				--     capabilities = capabilities,
				--     filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
				--   })
				-- end,

				-- ["svls"] = function()
				-- 	-- configure emmet language server
				-- 	lspconfig["svls"].setup({
				-- 		capabilities = capabilities,
				-- 		root_dir = function(fname)
				-- 			return require("lspconfig.util").find_git_ancestor(fname)
				-- 		end,
				-- 		cmd = { "svls" },
				-- 		filetypes = { "verilog", "systemverilog" },
				-- 	})
				-- end,

				["lua_ls"] = function()
					-- configure lua server (with special settings)
					lspconfig["lua_ls"].setup({
						capabilities = capabilities,
						settings = {
							Lua = {
								-- make the language server recognize "vim" global
								diagnostics = {
									globals = { "vim" },
								},
								completion = {
									callSnippet = "Replace",
								},
							},
						},
					})
				end,
			})
		end,
	},
}
