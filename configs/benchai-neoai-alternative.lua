-- BenchAI Integration for Neovim - NeoAI Alternative
-- Use this if Avante.nvim continues to have issues
-- NeoAI is simpler and better supports custom OpenAI endpoints

return {
  {
    "Bryley/neoai.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    cmd = {
      "NeoAI",
      "NeoAIOpen",
      "NeoAIClose",
      "NeoAIToggle",
      "NeoAIContext",
      "NeoAIContextOpen",
      "NeoAIContextClose",
      "NeoAIInject",
      "NeoAIInjectCode",
      "NeoAIInjectContext",
      "NeoAIInjectContextCode",
    },
    keys = {
      { "<leader>ai", "<cmd>NeoAIToggle<cr>", desc = "Toggle BenchAI" },
      { "<leader>ac", "<cmd>NeoAIContext<cr>", desc = "BenchAI Context" },
      { mode = "v", "<leader>ai", ":<c-u>NeoAIContext<cr>", desc = "BenchAI Context (Selection)" },
    },
    config = function()
      require("neoai").setup({
        -- Use BenchAI as the backend
        models = {
          {
            name = "benchai",
            model = "auto",
            params = {
              url = "http://192.168.0.213:8085/v1/chat/completions",
            },
          },
        },

        -- UI Configuration
        ui = {
          output_popup_text = "BenchAI",
          input_popup_text = "Prompt",
          width = 40,
          output_popup_height = 80,
          submit = "<Enter>",
        },

        -- Prompts for different use cases
        prompts = {
          context_prompt = function(context)
            return "I'd like to provide some context:\n\n"
              .. context
          end,
        },

        -- OpenAI-compatible options
        open_ai = {
          api_key = {
            env = "BENCHAI_KEY",
            value = "not-needed",
          },
        },

        -- Shortcuts
        shortcuts = {
          {
            name = "explain",
            key = "<leader>ae",
            desc = "Explain Code",
            use_context = true,
            prompt = "Explain the following code:",
            modes = { "v" },
            strip_function = nil,
          },
          {
            name = "improve",
            key = "<leader>ar",
            desc = "Refactor Code",
            use_context = true,
            prompt = "Suggest improvements for this code:",
            modes = { "v" },
            strip_function = nil,
          },
          {
            name = "fixbugs",
            key = "<leader>af",
            desc = "Fix Bugs",
            use_context = true,
            prompt = "Find and fix bugs in this code:",
            modes = { "v" },
            strip_function = nil,
          },
        },
      })
    end,
  },
}
