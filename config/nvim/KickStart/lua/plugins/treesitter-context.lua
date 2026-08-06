-- Sticky header showing the enclosing function/class as you scroll.
--
-- NOTE: this used to be a dependency of nvim-treesitter, which has been removed
-- (see the Treesitter section of lua/config/autocmds.lua for why). It does not
-- need nvim-treesitter --
-- it talks to Neovim's built-in vim.treesitter and ships its own queries for
-- ~86 languages. It only shows context in buffers that actually have a parser,
-- which out of the box means the languages bundled with Neovim.
---@module "lazy"
---@type LazySpec
return {
	"nvim-treesitter/nvim-treesitter-context",
	event = "BufReadPost",
	opts = {
		max_lines = 4,
		multiline_threshold = 2,
	},
}
