return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
  },
  config = function()
    require('neo-tree').setup {
      filesystem = {
        window = {
          mappings = {
            ['<cr>'] = 'open',
            ['o'] = 'open',
            ['<esc>'] = 'close_window',
          },
        },
        hijack_netrw_behavior = 'open_default',
      },
    }

    -- Keymaps
    vim.keymap.set('n', '<leader>fb', ':Neotree toggle<CR>', { desc = 'Toggle NeoTree' })
    vim.keymap.set('n', '<leader>cf', ':Neotree reveal<CR>', { desc = 'NeoTree reveal current file' })

    -- Atajos adicionales para crear archivos
    vim.keymap.set('n', '<leader>nf', ':edit ', { desc = 'New file anywhere' })
    vim.keymap.set('n', '<leader>cd', function()
      local path = vim.fn.input 'Create file with path: '
      if path ~= '' then
        vim.fn.mkdir(vim.fn.fnamemodify(path, ':h'), 'p')
        vim.cmd('edit ' .. path)
      end
    end, { desc = 'Create file with directories' })
  end,
}
