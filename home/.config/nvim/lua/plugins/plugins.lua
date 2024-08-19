local Util = require("lazyvim.util")

return {
  -- { "marko-cerovac/material.nvim" },
  -- { "olimorris/onedarkpro.nvim" },
  -- { "Mofiqul/adwaita.nvim" },
  -- { "projekt0n/github-nvim-theme" },
  -- { "dasupradyumna/midnight.nvim" },
  { "nyoom-engineering/oxocarbon.nvim" },
  { "projekt0n/github-nvim-theme" },
  -- { "oxfist/night-owl.nvim" },
  {
    "oxfist/night-owl.nvim",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "night-owl",
    },
  },
  {
    "f-person/auto-dark-mode.nvim",
    opts = {
      update_interval = 1000,
      set_dark_mode = function()
        vim.api.nvim_set_option("background", "dark")
        vim.cmd("colorscheme night-owl")
      end,
      set_light_mode = function()
        vim.api.nvim_set_option("background", "light")
        vim.cmd("colorscheme catppuccin-latte")
      end,
    },
  },
  { "folke/flash.nvim", enabled = false },
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        separator_style = "slant",
        always_show_bufferline = true,
        tab_size = 24,
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        section_separators = { left = '', right = '' },
      },
      sections = {
        lualine_z = {
        },
      },
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = {
      { "<leader>E", false },
      { "<leader>e", false },
      {
        "<leader>fE",
        function()
          require("neo-tree.command").execute({ toggle = true, position = "right", dir = vim.loop.cwd() })
        end,
        desc = "Explorer NeoTree (cwd)",
      },
      {
        "<leader>ge",
        function()
          require("neo-tree.command").execute({ source = "git_status", position = "right", toggle = true })
        end,
        desc = "Git explorer",
      },
      {
        "<leader>be",
        function()
          require("neo-tree.command").execute({ source = "buffers", position = "right", toggle = true })
        end,
        desc = "Buffer explorer",
      },
    },
  },
  {
    "echasnovski/mini.files",
    opts = {
      options = {
        -- Whether to use for editing directories
        -- Disabled by default in LazyVim because neo-tree is used for that
        use_as_default_explorer = true,
      },
    },
    keys = {
      {
        "<leader>e",
        function()
          require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
        end,
        desc = "Open mini.files (Directory of Current File)",
        remap = true
      },
      {
        "<leader>E",
        function()
          require("mini.files").open(vim.uv.cwd(), true)
        end,
        desc = "Open mini.files (cwd)",
        remap = true
      },
    },
  },
  {
    "akinsho/toggleterm.nvim",
    init = function()
      vim.keymap.set("t", "<ESC>", "<C-\\><C-n>", { noremap = true, silent = true })
    end,
    opts = {
      shading_factor = -30,
      direction = "horizontal",
      persist_mode = false,
      float_opts = {
        border = "curved",
        winblend = 5,
      },
    },
    keys = {
      {
        "<leader>1",
        function()
          require("toggleterm").toggle(1, 0, Util.root.get(), "horizontal")
        end,
        desc = "Terminal 1",
      },
      {
        "<leader>2",
        function()
          require("toggleterm").toggle(2, 0, Util.root.get(), "horizontal")
        end,
        desc = "Terminal 2",
      },
      {
        "<F4>",
        function()
          require("toggleterm").toggle(3, 0, Util.root.get(), "float")
        end,
        desc = "Floating terminal",
      },
    },
  },
  {
    "mfussenegger/nvim-dap",
    config = function()
      local ok, dap = pcall(require, "dap")
      if not ok then
        return
      end
      dap.configurations.typescript = {
        {
	  type = "pwa-node",
	  request = "attach",
	  name = "Auto Attach",
	  cwd = vim.fn.getcwd(),
          protocol = "inspector"
	}
      }
      dap.configurations.javascript = dap.configurations.typescript
    end,
  },
  -- Use <tab> for completion and snippets (supertab)
  -- first: disable default <tab> and <s-tab> behavior in LuaSnip
  {
    "L3MON4D3/LuaSnip",
    keys = function()
      return {}
    end,
  },
  -- then: setup supertab in cmp
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-emoji",
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local luasnip = require("luasnip")
      local cmp = require("cmp")

      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
            -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
            -- this way you will only jump inside the snippet region
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      })
    end,
  },
  -- { "lewis6991/satellite.nvim", opts = {}, event = "VeryLazy", enabled = false },
}
