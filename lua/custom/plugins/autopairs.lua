-- ~/.config/nvim/lua/plugins/autopairs.lua
return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter', -- Se carga solo al entrar en modo insert
  config = function()
    require('nvim-autopairs').setup {
      disable_filetype = { 'TelescopePrompt', 'vim' }, -- Opcional: evita conflictos
      check_ts = true, -- Si usas Treesitter, mejora el comportamiento
    }
  end,
}
