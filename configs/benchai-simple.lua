-- BenchAI Simple Plugin - Direct HTTP Integration
-- No dependencies, just works
-- Uses Neovim's built-in job control for HTTP requests

local M = {}

-- Configuration
local config = {
  url = "http://192.168.0.213:8085/v1/chat/completions",
  model = "auto",
  max_tokens = 2048,
  temperature = 0.7,
}

-- Helper to show response in a floating window
local function show_response(response)
  local buf = vim.api.nvim_create_buf(false, true)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local opts = {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " BenchAI ",
    title_pos = "center",
  }

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(response, "\n"))
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "filetype", "markdown")

  local win = vim.api.nvim_open_win(buf, true, opts)
  vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", ":close<CR>", { noremap = true, silent = true })
end

-- Make API request using curl
local function call_benchai(prompt, context, callback)
  local messages = {}

  if context and context ~= "" then
    table.insert(messages, {
      role = "user",
      content = "Here is the code for context:\n\n```\n" .. context .. "\n```"
    })
  end

  table.insert(messages, {
    role = "user",
    content = prompt
  })

  local payload = vim.fn.json_encode({
    model = config.model,
    messages = messages,
    max_tokens = config.max_tokens,
    temperature = config.temperature,
    stream = false,
  })

  -- Write payload to temp file to avoid escaping issues
  local temp_file = vim.fn.tempname()
  local f = io.open(temp_file, "w")
  f:write(payload)
  f:close()

  local curl_cmd = string.format(
    "curl -s -X POST '%s' -H 'Content-Type: application/json' -d @%s; rm %s",
    config.url,
    temp_file,
    temp_file
  )

  vim.fn.jobstart(curl_cmd, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data and #data > 0 then
        local response_text = table.concat(data, "\n")
        local ok, response = pcall(vim.fn.json_decode, response_text)

        if ok and response.choices and response.choices[1] then
          local content = response.choices[1].message.content
          callback(content)
        else
          callback("Error: Invalid response from server\n\n" .. response_text)
        end
      end
    end,
    on_stderr = function(_, data)
      if data and #data > 0 then
        callback("Error: " .. table.concat(data, "\n"))
      end
    end,
  })
end

-- Command: Ask BenchAI with input
function M.ask()
  vim.ui.input({ prompt = "Ask BenchAI: " }, function(input)
    if not input or input == "" then return end

    vim.notify("Asking BenchAI...", vim.log.levels.INFO)

    call_benchai(input, nil, function(response)
      show_response(response)
    end)
  end)
end

-- Command: Explain selected code
function M.explain_selection()
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local code = table.concat(lines, "\n")

  if code == "" then
    vim.notify("No code selected", vim.log.levels.WARN)
    return
  end

  vim.notify("Explaining code...", vim.log.levels.INFO)

  call_benchai("Explain this code clearly and concisely.", code, function(response)
    show_response(response)
  end)
end

-- Command: Improve selected code
function M.improve_selection()
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local code = table.concat(lines, "\n")

  if code == "" then
    vim.notify("No code selected", vim.log.levels.WARN)
    return
  end

  vim.notify("Getting improvements...", vim.log.levels.INFO)

  call_benchai("Suggest improvements for this code and provide the improved version.", code, function(response)
    show_response(response)
  end)
end

-- Command: Fix bugs in selected code
function M.fix_bugs()
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local code = table.concat(lines, "\n")

  if code == "" then
    vim.notify("No code selected", vim.log.levels.WARN)
    return
  end

  vim.notify("Finding bugs...", vim.log.levels.INFO)

  call_benchai("Find and fix bugs in this code. Explain the issues and provide the fixed version.", code, function(response)
    show_response(response)
  end)
end

-- Setup keymaps and commands
function M.setup()
  -- Commands
  vim.api.nvim_create_user_command("BenchAI", M.ask, {})
  vim.api.nvim_create_user_command("BenchAIExplain", M.explain_selection, { range = true })
  vim.api.nvim_create_user_command("BenchAIImprove", M.improve_selection, { range = true })
  vim.api.nvim_create_user_command("BenchAIFix", M.fix_bugs, { range = true })

  -- Keymaps
  vim.keymap.set("n", "<leader>aa", M.ask, { desc = "Ask BenchAI" })
  vim.keymap.set("v", "<leader>ae", ":<C-u>BenchAIExplain<CR>", { desc = "Explain Code" })
  vim.keymap.set("v", "<leader>ar", ":<C-u>BenchAIImprove<CR>", { desc = "Improve Code" })
  vim.keymap.set("v", "<leader>af", ":<C-u>BenchAIFix<CR>", { desc = "Fix Bugs" })
end

return {
  "benchai-simple",
  dir = vim.fn.stdpath("config") .. "/lua/plugins",
  name = "benchai-simple",
  config = function()
    M.setup()
    vim.notify("BenchAI loaded - Use <leader>aa to chat", vim.log.levels.INFO)
  end,
}
