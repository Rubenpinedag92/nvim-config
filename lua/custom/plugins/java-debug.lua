-- ~/.config/nvim/lua/plugins/java-debug.lua
-- Configuración para debugging de Java en Neovim con Kickstart

return {
  -- Plugin principal para DAP (Debug Adapter Protocol)
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'theHamsta/nvim-dap-virtual-text',
      'nvim-neotest/nvim-nio',
    },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'

      -- Configuración de nvim-dap-ui
      dapui.setup()

      -- Configuración de virtual text
      require('nvim-dap-virtual-text').setup()

      -- Auto-abrir/cerrar DAP UI
      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated['dapui_config'] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited['dapui_config'] = function()
        dapui.close()
      end

      -- Keymaps para debugging
      vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
      vim.keymap.set('n', '<F1>', dap.step_into, { desc = 'Debug: Step Into' })
      vim.keymap.set('n', '<F2>', dap.step_over, { desc = 'Debug: Step Over' })
      vim.keymap.set('n', '<F3>', dap.step_out, { desc = 'Debug: Step Out' })
      vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
      vim.keymap.set('n', '<leader>B', function()
        dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end, { desc = 'Debug: Set Conditional Breakpoint' })
      vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })
    end,
  },

  -- Plugin para Java LSP con soporte para debugging
  {
    'mfussenegger/nvim-jdtls',
    ft = 'java',
    config = function()
      local jdtls = require 'jdtls'
      local home = os.getenv 'HOME'

      -- Detectar sistema operativo
      local config_dir = 'config_linux'
      if vim.fn.has 'mac' == 1 then
        config_dir = 'config_mac'
      elseif vim.fn.has 'win32' == 1 then
        config_dir = 'config_win'
      end

      -- Paths importantes
      local workspace_path = home .. '/.local/share/eclipse-workspaces/'
      local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
      local workspace_dir = workspace_path .. project_name

      -- Función para encontrar jar files de manera más robusta
      local function find_jar(pattern)
        local jar_files = vim.fn.glob(pattern, false, true)
        if #jar_files > 0 then
          return jar_files[1]
        end
        return nil
      end

      -- Buscar el jar de Eclipse Launcher
      local launcher_jar = find_jar(home .. '/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar')
      if not launcher_jar then
        vim.notify('Error: No se encontró el launcher jar de JDTLS', vim.log.levels.ERROR)
        return
      end

      -- Verificar que el directorio de configuración existe
      local config_path = home .. '/.local/share/nvim/mason/packages/jdtls/' .. config_dir
      if vim.fn.isdirectory(config_path) == 0 then
        vim.notify('Error: Directorio de configuración JDTLS no encontrado: ' .. config_path, vim.log.levels.ERROR)
        return
      end

      -- Configuración de JDTLS
      local config = {
        cmd = {
          'java',
          '-Declipse.application=org.eclipse.jdt.ls.core.id1',
          '-Dosgi.bundles.defaultStartLevel=4',
          '-Declipse.product=org.eclipse.jdt.ls.core.product',
          '-Dlog.protocol=true',
          '-Dlog.level=ERROR', -- Cambio crítico: reducir logging
          '-Xmx2g', -- Aumentar memoria
          '-Xms512m',
          '--add-modules=ALL-SYSTEM',
          '--add-opens',
          'java.base/java.util=ALL-UNNAMED',
          '--add-opens',
          'java.base/java.lang=ALL-UNNAMED',
          '--add-opens',
          'java.base/java.lang.reflect=ALL-UNNAMED',
          '--add-opens',
          'java.base/java.nio.file=ALL-UNNAMED',
          '--add-opens',
          'java.base/java.net=ALL-UNNAMED',
          '--add-opens',
          'java.base/sun.nio.ch=ALL-UNNAMED',
          '--add-opens',
          'java.management/sun.management=ALL-UNNAMED',
          '--add-opens',
          'java.base/sun.security.util=ALL-UNNAMED',
          '--enable-native-access=ALL-UNNAMED',
          '-XX:+UseZGC', -- Usar ZGC si está disponible
          '-Dsun.zip.disableMemoryMapping=true',
          '-Djava.import.generatesMetadataFilesAtProjectRoot=false',
          '-jar',
          launcher_jar,
          '-configuration',
          config_path,
          '-data',
          workspace_dir,
        },

        root_dir = require('jdtls.setup').find_root { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' },

        settings = {
          java = {
            eclipse = {
              downloadSources = true,
            },
            configuration = {
              updateBuildConfiguration = 'interactive',
            },
            maven = {
              downloadSources = true,
            },
            implementationsCodeLens = {
              enabled = true,
            },
            referencesCodeLens = {
              enabled = true,
            },
            references = {
              includeDecompiledSources = true,
            },
            format = {
              enabled = true,
            },
          },
          signatureHelp = { enabled = true },
          completion = {
            favoriteStaticMembers = {
              'org.hamcrest.MatcherAssert.assertThat',
              'org.hamcrest.Matchers.*',
              'org.hamcrest.CoreMatchers.*',
              'org.junit.jupiter.api.Assertions.*',
              'java.util.Objects.requireNonNull',
              'java.util.Objects.requireNonNullElse',
              'org.mockito.Mockito.*',
            },
          },
          contentProvider = { preferred = 'fernflower' },
          extendedClientCapabilities = jdtls.extendedClientCapabilities,
          sources = {
            organizeImports = {
              starThreshold = 9999,
              staticStarThreshold = 9999,
            },
          },
          codeGeneration = {
            toString = {
              template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}',
            },
            useBlocks = true,
          },
        },

        -- Inicialización con capacidades de debugging
        init_options = {
          bundles = {
            vim.fn.glob(home .. '/.local/share/nvim/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar', true),
          },
        },
      }

      -- Configuración de debugging específica para Java
      config.on_attach = function(client, bufnr)
        -- Configurar DAP para Java
        jdtls.setup_dap { hotcodereplace = 'auto' }
        require('jdtls.dap').setup_dap_main_class_configs()

        -- Keymaps específicos para Java
        local opts = { buffer = bufnr }
        vim.keymap.set('n', '<leader>co', jdtls.organize_imports, vim.tbl_extend('force', opts, { desc = 'Organize Imports' }))
        vim.keymap.set('n', '<leader>crv', jdtls.extract_variable, vim.tbl_extend('force', opts, { desc = 'Extract Variable' }))
        vim.keymap.set('n', '<leader>crc', jdtls.extract_constant, vim.tbl_extend('force', opts, { desc = 'Extract Constant' }))
        vim.keymap.set(
          'v',
          '<leader>crm',
          [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]],
          vim.tbl_extend('force', opts, { desc = 'Extract Method' })
        )
        vim.keymap.set('n', '<leader>cru', jdtls.update_projects_config, vim.tbl_extend('force', opts, { desc = 'Update Projects' }))
      end

      -- Iniciar JDTLS
      jdtls.start_or_attach(config)
    end,
  },
}
