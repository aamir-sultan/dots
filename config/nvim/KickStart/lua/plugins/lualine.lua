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
  }
}

return {
   'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
   -- lazy = true,
   -- event = 'VimEnter',
   -- event = 'VeryLazy',
   ft = "*",
    opts = opts
}
