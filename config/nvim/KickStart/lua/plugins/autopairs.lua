-- Auto-close brackets/quotes.
-- Using mini.pairs rather than windwp/nvim-autopairs, since the latter's
-- recommended setup is wired to nvim-cmp and this config uses blink.cmp.
return {
	"nvim-mini/mini.pairs",
	version = "v0.17.0",
	lazy = true,
	event = "InsertEnter",
	opts = {},
}
