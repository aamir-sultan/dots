return {
  'akinsho/bufferline.nvim',
  event = { 'BufReadPost' },
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  version = '*',
  opts = {
    options = {
      -- separator_style: "slant" | "slope" | "thick" | "thin" | { 'any', 'any' }
      indicator = {
        icon = ' ',
        style = 'icon',
      },
      mode = 'buffers', -- was 'bufffers' (typo); valid values are 'buffers' | 'tabs'
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
  -- NOTE: `config` and the session-restore fix used to be nested inside
  -- `opts.options`, where lazy.nvim never looked at them, so neither ran.
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
