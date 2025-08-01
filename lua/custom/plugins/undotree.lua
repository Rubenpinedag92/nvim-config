return {
  'jiaoshijie/undotree', -- versión en Lua, más moderna
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = {
    { '<leader>u', "<cmd>lua require('undotree').toggle()<CR>", desc = 'Toggle Undotree' },
  },
  config = function()
    require('undotree').setup {
      float_diff = true,
      layout = 'left_bottom',
      position = 'left',
      window = { winblend = 20 },
      ignore_filetype = { 'undotree', 'undotreeDiff', 'qf', 'TelescopePrompt' },
      keymaps = {
        ['j'] = 'move_next',
        ['k'] = 'move_prev',
        ['J'] = 'move_change_next',
        ['K'] = 'move_change_prev',
        ['<cr>'] = 'action_enter',
        ['p'] = 'enter_diffbuf',
        ['q'] = 'quit',
      },
    }
  end,
}
