-- BenchAI Integration for Neovim - NeoAI (Recommended)
-- More reliable than Avante for custom OpenAI-compatible endpoints
-- Works with LazyVim out of the box

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
      { "<leader>aa", "<cmd>NeoAIToggle<cr>", desc = "Toggle BenchAI Chat" },
      { "<leader>ac", "<cmd>NeoAIContext<cr>", desc = "BenchAI with Context" },
      { "<leader>ag", "<cmd>NeoAIShortcut gitcommit<cr>", desc = "Generate Git Commit" },
      { mode = "v", "<leader>aa", ":<c-u>'<,'>NeoAIContext<cr>", desc = "BenchAI with Selection" },
      { mode = "v", "<leader>ae", ":<c-u>'<,'>NeoAIInject explain<cr>", desc = "Explain Code" },
      { mode = "v", "<leader>ar", ":<c-u>'<,'>NeoAIInject improve<cr>", desc = "Improve Code" },
      { mode = "v", "<leader>af", ":<c-u>'<,'>NeoAIInject fixbugs<cr>", desc = "Fix Bugs" },
    },
    config = function()
      require("neoai").setup({
        -- BenchAI as OpenAI-compatible backend
        ui = {
          output_popup_text = "BenchAI",
          input_popup_text = "Prompt",
          width = 40,
          output_popup_height = 80,
          submit = "<Enter>",
        },

        -- Model configuration
        models = {
          {
            name = "openai",
            model = "auto",
            params = {
              url = "http://192.168.0.213:8085/v1/chat/completions",
            },
          },
        },

        -- Register custom prompts/shortcuts
        register_output = {
          ["g"] = function(output)
            return output
          end,
        },

        -- Shortcuts for common operations
        shortcuts = {
          {
            name = "explain",
            key = "<leader>ae",
            desc = "Explain Code",
            use_context = true,
            prompt = [[
Explain the following code clearly and concisely:
- What it does
- How it works
- Any important patterns or techniques used
]],
            modes = { "v" },
            strip_function = nil,
          },
          {
            name = "improve",
            key = "<leader>ar",
            desc = "Improve/Refactor Code",
            use_context = true,
            prompt = [[
Suggest improvements for this code:
- Better patterns or practices
- Performance optimizations
- Readability improvements
Provide the improved code.
]],
            modes = { "v" },
            strip_function = nil,
          },
          {
            name = "fixbugs",
            key = "<leader>af",
            desc = "Find and Fix Bugs",
            use_context = true,
            prompt = [[
Analyze this code for bugs and issues:
- Identify any bugs or potential issues
- Explain the problems
- Provide the fixed code
]],
            modes = { "v" },
            strip_function = nil,
          },
          {
            name = "gitcommit",
            key = "<leader>ag",
            desc = "Generate Git Commit Message",
            use_context = false,
            prompt = function()
              return [[
Write a concise git commit message for these changes.
Use conventional commit format (feat:, fix:, docs:, etc.)
Keep the first line under 72 characters.
]]
            end,
            modes = { "n" },
            strip_function = nil,
          },
          {
            name = "tests",
            key = "<leader>at",
            desc = "Generate Tests",
            use_context = true,
            prompt = [[
Write unit tests for this code:
- Cover main functionality
- Include edge cases
- Use appropriate testing framework
]],
            modes = { "v" },
            strip_function = nil,
          },
          {
            name = "docs",
            key = "<leader>ad",
            desc = "Generate Documentation",
            use_context = true,
            prompt = [[
Write documentation for this code:
- Function/method signatures
- Parameters and return values
- Usage examples
Use appropriate docstring format.
]],
            modes = { "v" },
            strip_function = nil,
          },
        },

        -- Inject prompts
        inject = {
          cutoff_width = 80,
        },

        -- Prompts
        prompts = {
          context_prompt = function(context)
            return "Here is the code/context:\n\n```\n" .. context .. "\n```\n\n"
          end,
        },

        -- OpenAI-compatible settings (will be overridden by environment)
        open_ai = {
          api_key = {
            env = "OPENAI_API_KEY",
            value = "not-needed",
            get = function()
              return "not-needed"
            end,
          },
        },
      })
    end,
  },
}
