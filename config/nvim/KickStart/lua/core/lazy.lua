local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		-- Not a pin: "*" floats to the newest release tag. Needed anyway --
		-- left alone lazy manages itself on `main` (unreleased commits) while
		-- the bootstrap above clones `stable`, so the two would diverge.
		{ "folke/lazy.nvim", version = "*" },
		-- import your plugins
		{ import = "plugins" },
	},
	-- Records the exact commit of every plugin. Committed with the config
	-- (stdpath("config") is a symlink into this repo). Note lazy's *install*
	-- path ignores it -- only `:Lazy restore` applies it -- so the pins in
	-- lua/plugins/* are what make a fresh install reproducible; this is the
	-- exact record and the rollback mechanism.
	--   :Lazy restore  force every plugin to the locked commit
	--   :Lazy sync     match the specs, then rewrite this file (commit it)
	--   :Lazy check    show upstream changes without touching anything
	lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json",

	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	install = { colorscheme = { "habamax" } },
	-- automatically check for plugin updates
	checker = {
		enabled = true, -- check for plugin updates periodically
		notify = false, -- notify on update
	},
	performance = {
		rtp = {
			-- disable some rtp plugins
			disabled_plugins = {
				-- "gzip",
				-- "matchit",
				-- "matchparen",
				"netrwPlugin",
				-- "tarPlugin",
				"tohtml",
				"tutor",
				-- "zipPlugin",
			},
		},
	},
})
