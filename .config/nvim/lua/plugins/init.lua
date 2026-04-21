return {
  {
    "stevearc/conform.nvim",
    -- event = 'bufwritepre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- these are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  -- {
    -- 	"nvim-treesitter/nvim-treesitter",
    -- 	opts = {
      -- 		ensure_installed = {
        -- 			"vim", "lua", "vimdoc",
        --      "html", "css"
        -- 		},
        -- 	},
        -- },
        --
        {
          "zbirenbaum/copilot.lua",
          cmd = "Copilot",           -- C mayúscula
          event = "InsertEnter",     -- I y E mayúsculas
          config = function()
            require("copilot").setup({
              suggestion = {
                enabled = true,
                auto_trigger = true,
                keymap = {
                  accept = "<Tab>",  -- T mayúscula
                  dismiss = "<C-]>",
                },
              },
              panel = { enabled = false },
            })
          end,
        },

        {
          "CopilotC-Nvim/CopilotChat.nvim",
          branch = "main",
          cmd = { "CopilotChat", "CopilotChatExplain", "CopilotChatFix", "CopilotChatOptimize", "CopilotChatTests" },
          dependencies = {
            { "zbirenbaum/copilot.lua" },
            { "nvim-lua/plenary.nvim" },
          },
          opts = {
            show_help = true,
            auto_follow_cursor = false,
          },
        },

        {
          "yetone/avante.nvim",
          event = "VeryLazy",
          build = "make",
          dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "stevearc/dressing.nvim",
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "zbirenbaum/copilot.lua",
          },
          opts = {
            provider = "copilot",
          },
        },
}
