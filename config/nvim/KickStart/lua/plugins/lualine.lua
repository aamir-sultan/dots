local local_opts = {
  -- component_separators = { left = '', right = '' },
  -- section_separators = { left = '', right = '' },
  component_separators = { left = '', right = '' },
  section_separators = { left = '', right = '' },
}

local opts = -- Keep the outer brackets of options otherwise won't work
  {
    options = {
      component_separators = { left = '', right = '' },
      section_separators = { left = '', right = '' },
    },
  }

return {
  'nvim-lualine/lualine.nvim',
  -- No tags upstream.
  commit = '221ce6b2d999187044529f49da6554a92f740a96', -- 2026-05-31
  -- nvim-web-devicons is pinned in neo-tree.lua (lazy merges specs by name).
  dependencies = { 'nvim-tree/nvim-web-devicons', event = 'BufReadPost' },
  -- lazy = true,
  -- event = 'VimEnter',
  event = 'BufReadPost',
  -- ft = '*',
  opts = opts,
}
