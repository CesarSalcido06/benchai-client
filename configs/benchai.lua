-- BenchAI Integration for Neovim/LazyVim
-- Provides AI assistance using local BenchAI router

return {
  -- Avante.nvim - Cursor-like AI experience
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false,
    opts = {
      -- Use OpenAI provider (most stable for custom endpoints)
      provider = "openai",
      auto_suggestions_provider = "openai",

      openai = {
        endpoint = "http://192.168.0.213:8085/v1",
        model = "auto",
        timeout = 30000, -- 30 seconds to avoid hangs
        temperature = 0.7,
        max_tokens = 2048, -- Reduced to prevent infinite generation
      },

      -- Behavior settings (auto_suggestions disabled to prevent hangs)
      behaviour = {
        auto_suggestions = false,
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_apply_diff_after_generation = false,
        support_paste_from_clipboard = true,
      },

      -- Key mappings
      mappings = {
        diff = {
          ours = "co",
          theirs = "ct",
          all_theirs = "ca",
          both = "cb",
          cursor = "cc",
          next = "]x",
          prev = "[x",
        },
        suggestion = {
          accept = "<M-l>",
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
        jump = {
          next = "]]",
          prev = "[[",
        },
        submit = {
          normal = "<CR>",
          insert = "<C-s>",
        },
        sidebar = {
          switch_windows = "<Tab>",
          reverse_switch_windows = "<S-Tab>",
        },
      },

      -- Window settings
      windows = {
        position = "right",
        wrap = true,
        width = 40,
        sidebar_header = {
          align = "center",
          rounded = true,
        },
      },

      hints = { enabled = true },
    },

    build = "make",

    dependencies = {
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
      {
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = { insert_mode = true },
          },
        },
      },
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = { file_types = { "markdown", "Avante" } },
        ft = { "markdown", "Avante" },
      },
    },
  },
}
