return {
  'akinsho/bufferline.nvim',
  event = { 'BufReadPost' },
  -- nvim-web-devicons is pinned in neo-tree.lua (lazy merges specs by name).
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  version = 'v4.9.1', -- 2025-01-14, latest release (was floating '*')
  opts = {
    options = {
      -- separator_style: "slant" | "slope" | "thick" | "thin" | { 'any', 'any' }
      indicator = {
        icon = ' ',
        style = 'icon',
      },
      mode = 'buffers', -- 'buffers' | 'tabs'
      diagnostics = 'nvim_lsp',
      offsets = {
        {
          filetype = 'neo-tree',
          text = 'Neo-Tree',
          separator = true,
          text_align = 'left',
        },
      },
    },
  },
  -- `config` must be at spec level; it used to be nested in `opts.options`,
  -- where lazy never looked, so it never ran.
  config = function(_, opts)
    require('bufferline').setup(opts)
    -- Refresh bufferline when a session is restored, otherwise the tabline
    -- can come back empty or stale.
    vim.api.nvim_create_autocmd({ 'BufAdd', 'BufDelete' }, {
      group = vim.api.nvim_create_augroup('bufferline_refresh', { clear = true }),
      callback = function()
        vim.schedule(function()
          pcall(vim.cmd, 'redrawtabline')
        end)
      end,
    })
  end,
}
