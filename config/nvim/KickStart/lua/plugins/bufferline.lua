return {
  'akinsho/bufferline.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  version = '*',
  opts = {
    options = {
      -- mode = 'tabs',
      mode = 'bufffers',
      diagnostics = 'nvim_lsp',
      offsets = {
        {
          filetype = 'neo-tree',
          text = 'Noe-Tree',
          separator = true,
          text_align = 'left',
        },
      },

      diagnostics_indicator = function(count, level, diagnostics_dict, context)
        if context.buffer:current() then
          return ''
        end

        return ''
      end,

      config = function(_, opts)
        require('bufferline').setup(opts)
        -- Fix bufferline when restoring a session
        vim.api.nvim_create_autocmd({ 'BufAdd', 'BufDelete' }, {
          callback = function()
            vim.schedule(function()
              pcall(nvim_bufferline)
            end)
          end,
        })
      end,
    },
  },
}
