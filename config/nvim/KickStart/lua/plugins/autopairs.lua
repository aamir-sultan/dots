-- Auto-close brackets/quotes. mini.pairs rather than nvim-autopairs, whose
-- recommended setup is wired to nvim-cmp (this config uses blink.cmp).
return {
	"nvim-mini/mini.pairs",
	version = "v0.18.0", -- 2026-06-19 (was v0.17.0)
	lazy = true,
	event = "InsertEnter",
	opts = {},
}
