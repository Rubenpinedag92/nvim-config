return {
  'nvim-telescope/telescope-file-browser.nvim',
  dependencies = {
    'nvim-telescope/telescope.nvim',
    'nvim-lua/plenary.nvim',
  },
  config = function()
    require('telescope').load_extension 'file_browser'

    -- Configurar telescope-file-browser
    require('telescope').setup {
      extensions = {
        file_browser = {
          theme = 'ivy',
          hijack_netrw = true, -- Reemplaza netrw
          mappings = {
            ['i'] = {
              -- Atajos en modo inserción
            },
            ['n'] = {
              -- Atajos en modo normal
            },
          },
        },
      },
    }

    -- Atajos para el file browser
    vim.keymap.set('n', '<leader>fb', ':Telescope file_browser<CR>', { desc = 'File browser' })
    vim.keymap.set('n', '<leader>cf', ':Telescope file_browser path=%:p:h select_buffer=true<CR>', { desc = 'File browser current dir' })

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
