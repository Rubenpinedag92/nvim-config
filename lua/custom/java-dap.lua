return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui', -- Interfaz visual
    'theHamsta/nvim-dap-virtual-text', -- Inline hints
    'nvim-neotest/nvim-nio', -- ✅ Nueva dependencia requerida
  },
  config = function()
    local dap = require 'dap'
    require('dapui').setup()
    require('nvim-dap-virtual-text').setup()

    -- Abrir/cerrar UI automáticamente
    dap.listeners.after.event_initialized['dapui_config'] = function()
      require('dapui').open()
    end
    dap.listeners.before.event_terminated['dapui_config'] = function()
      require('dapui').close()
    end
    dap.listeners.before.event_exited['dapui_config'] = function()
      require('dapui').close()
    end
  end,
}
