-- Sticky header showing the enclosing function/class as you scroll.
-- Standalone: uses Neovim's built-in vim.treesitter and ships its own queries.
-- Only active in buffers that have a parser (see autocmds.lua).
---@module "lazy"
---@type LazySpec
return {
	"nvim-treesitter/nvim-treesitter-context",
	-- Commit-pinned: newest tag (v1.0.0) is from 2025-05.
	commit = "f3061339b8eaf9fda873600bc425b8d2d8502533", -- 2026-08-02
	event = "BufReadPost",
	opts = {
		max_lines = 4,
		multiline_threshold = 2,
	},
}
