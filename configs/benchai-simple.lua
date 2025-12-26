-- BenchAI - Professional Neovim Integration
-- Direct HTTP integration with proper UI

local M = {}

-- Configuration
local config = {
  url = "http://192.168.0.213:8085/v1/chat/completions",
  model = "auto",
  max_tokens = 2048,
  temperature = 0.7,
}

-- State
local state = {
  response_buf = nil,
  response_win = nil,
  input_buf = nil,
  input_win = nil,
}

-- Utility: Wrap text to fit width
local function wrap_text(text, width)
  local lines = {}
  for line in text:gmatch("[^\n]+") do
    if #line <= width then
      table.insert(lines, line)
    else
      -- Wrap long lines
      local pos = 1
      while pos <= #line do
        local chunk = line:sub(pos, pos + width - 1)
        -- Try to break at word boundary
        if pos + width <= #line then
          local last_space = chunk:reverse():find(" ")
          if last_space and last_space < width / 2 then
            chunk = chunk:sub(1, width - last_space)
          end
        end
        table.insert(lines, chunk)
        pos = pos + #chunk
      end
    end
  end
  return lines
end

-- Close all windows
local function close_windows()
  if state.response_win and vim.api.nvim_win_is_valid(state.response_win) then
    vim.api.nvim_win_close(state.response_win, true)
  end
  if state.input_win and vim.api.nvim_win_is_valid(state.input_win) then
    vim.api.nvim_win_close(state.input_win, true)
  end
  state.response_win = nil
  state.input_win = nil
end

-- Show response in professional floating window
local function show_response(content, is_error)
  close_windows()

  -- Create buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

  -- Calculate dimensions
  local width = math.min(100, math.floor(vim.o.columns * 0.8))
  local height = math.min(40, math.floor(vim.o.lines * 0.8))

  -- Wrap and set content
  local lines = wrap_text(content, width - 4)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)

  -- Window options
  local win_opts = {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = is_error and " Error " or " BenchAI Response ",
    title_pos = "center",
  }

  -- Open window
  state.response_win = vim.api.nvim_open_win(buf, true, win_opts)
  vim.api.nvim_win_set_option(state.response_win, "wrap", true)
  vim.api.nvim_win_set_option(state.response_win, "linebreak", true)

  -- Keymaps to close
  local close_keys = { "q", "<Esc>", "<CR>" }
  for _, key in ipairs(close_keys) do
    vim.api.nvim_buf_set_keymap(buf, "n", key, "", {
      callback = close_windows,
      noremap = true,
      silent = true,
    })
  end

  -- Auto-highlight code blocks
  vim.cmd([[syntax match BenchAICode /```\_.\{-}```/]])
  vim.cmd([[highlight BenchAICode guibg=#1e1e1e]])
end

-- Show loading indicator
local function show_loading(message)
  close_windows()

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
    "",
    "  " .. message,
    "",
    "  Press <Esc> to cancel",
    ""
  })
  vim.api.nvim_buf_set_option(buf, "modifiable", false)

  local win_opts = {
    relative = "editor",
    width = 40,
    height = 5,
    row = math.floor(vim.o.lines / 2) - 2,
    col = math.floor((vim.o.columns - 40) / 2),
    style = "minimal",
    border = "rounded",
    title = " BenchAI ",
    title_pos = "center",
  }

  state.response_win = vim.api.nvim_open_win(buf, false, win_opts)

  vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "", {
    callback = close_windows,
    noremap = true,
    silent = true,
  })
end

-- Make API call
local function call_benchai(prompt, context, on_success, on_error)
  local messages = {}

  if context and context ~= "" then
    table.insert(messages, {
      role = "user",
      content = "Here is code for context:\n\n```\n" .. context .. "\n```\n"
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

  -- Write to temp file
  local temp_file = vim.fn.tempname()
  local f = io.open(temp_file, "w")
  if not f then
    on_error("Failed to create temp file")
    return
  end
  f:write(payload)
  f:close()

  -- Build curl command
  local cmd = {
    "curl",
    "-s",
    "-X", "POST",
    config.url,
    "-H", "Content-Type: application/json",
    "-d", "@" .. temp_file,
  }

  local stdout_data = {}

  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data then
        vim.list_extend(stdout_data, data)
      end
    end,
    on_exit = function(_, exit_code)
      -- Clean up temp file
      os.remove(temp_file)

      if exit_code ~= 0 then
        on_error("Request failed with exit code " .. exit_code)
        return
      end

      local response_text = table.concat(stdout_data, "\n")
      if response_text == "" then
        on_error("Empty response from server")
        return
      end

      -- Parse JSON
      local ok, response = pcall(vim.fn.json_decode, response_text)
      if not ok then
        on_error("Invalid JSON response:\n\n" .. response_text)
        return
      end

      -- Extract content
      if response.choices and response.choices[1] and response.choices[1].message then
        local content = response.choices[1].message.content
        if content and content ~= "" then
          on_success(content)
        else
          on_error("Empty content in response")
        end
      else
        on_error("Unexpected response format:\n\n" .. vim.inspect(response))
      end
    end,
  })
end

-- Commands

-- Helper to get current paragraph or selection
local function get_code_context()
  -- Save current position
  local save_cursor = vim.fn.getcurpos()

  -- Select current paragraph
  vim.cmd("normal! vip")

  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

  -- Restore cursor position
  vim.fn.setpos('.', save_cursor)

  return table.concat(lines, "\n")
end

function M.ask()
  vim.ui.input({ prompt = "Ask BenchAI: " }, function(input)
    if not input or input == "" then return end

    show_loading("Thinking...")

    call_benchai(input, nil, function(response)
      show_response(response, false)
    end, function(error)
      show_response(error, true)
    end)
  end)
end

function M.explain_selection()
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local code = table.concat(lines, "\n")

  if code == "" then
    vim.notify("No code selected", vim.log.levels.WARN)
    return
  end

  show_loading("Analyzing code...")

  call_benchai(
    "Explain this code clearly. Include what it does, how it works, and any important patterns.",
    code,
    function(response) show_response(response, false) end,
    function(error) show_response(error, true) end
  )
end

function M.explain()
  local code = get_code_context()
  if code == "" then
    vim.notify("No code found", vim.log.levels.WARN)
    return
  end

  show_loading("Analyzing code...")

  call_benchai(
    "Explain this code clearly. Include what it does, how it works, and any important patterns.",
    code,
    function(response) show_response(response, false) end,
    function(error) show_response(error, true) end
  )
end

function M.improve_selection()
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local code = table.concat(lines, "\n")

  if code == "" then
    vim.notify("No code selected", vim.log.levels.WARN)
    return
  end

  show_loading("Improving code...")

  call_benchai(
    "Suggest improvements for this code. Focus on best practices, performance, and readability. Provide the improved code.",
    code,
    function(response) show_response(response, false) end,
    function(error) show_response(error, true) end
  )
end

function M.improve()
  local code = get_code_context()
  if code == "" then
    vim.notify("No code found", vim.log.levels.WARN)
    return
  end

  show_loading("Improving code...")

  call_benchai(
    "Suggest improvements for this code. Focus on best practices, performance, and readability. Provide the improved code.",
    code,
    function(response) show_response(response, false) end,
    function(error) show_response(error, true) end
  )
end

function M.fix_bugs()
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local code = table.concat(lines, "\n")

  if code == "" then
    vim.notify("No code selected", vim.log.levels.WARN)
    return
  end

  show_loading("Finding bugs...")

  call_benchai(
    "Analyze this code for bugs and issues. Explain the problems and provide fixed code.",
    code,
    function(response) show_response(response, false) end,
    function(error) show_response(error, true) end
  )
end

function M.fix()
  local code = get_code_context()
  if code == "" then
    vim.notify("No code found", vim.log.levels.WARN)
    return
  end

  show_loading("Finding bugs...")

  call_benchai(
    "Analyze this code for bugs and issues. Explain the problems and provide fixed code.",
    code,
    function(response) show_response(response, false) end,
    function(error) show_response(error, true) end
  )
end

function M.generate_tests()
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local code = table.concat(lines, "\n")

  if code == "" then
    vim.notify("No code selected", vim.log.levels.WARN)
    return
  end

  show_loading("Generating tests...")

  call_benchai(
    "Write comprehensive unit tests for this code. Include edge cases and use appropriate testing framework.",
    code,
    function(response) show_response(response, false) end,
    function(error) show_response(error, true) end
  )
end

function M.tests()
  local code = get_code_context()
  if code == "" then
    vim.notify("No code found", vim.log.levels.WARN)
    return
  end

  show_loading("Generating tests...")

  call_benchai(
    "Write comprehensive unit tests for this code. Include edge cases and use appropriate testing framework.",
    code,
    function(response) show_response(response, false) end,
    function(error) show_response(error, true) end
  )
end

-- Setup
function M.setup()
  -- User commands
  vim.api.nvim_create_user_command("BenchAI", M.ask, {})
  vim.api.nvim_create_user_command("BenchAIExplain", M.explain_selection, { range = true })
  vim.api.nvim_create_user_command("BenchAIImprove", M.improve_selection, { range = true })
  vim.api.nvim_create_user_command("BenchAIFix", M.fix_bugs, { range = true })
  vim.api.nvim_create_user_command("BenchAITest", M.generate_tests, { range = true })

  -- Keymaps (normal mode - works on current paragraph)
  vim.keymap.set("n", "<leader>aa", M.ask, { desc = "Ask BenchAI", silent = true })
  vim.keymap.set("n", "<leader>ae", M.explain, { desc = "Explain Code", silent = true })
  vim.keymap.set("n", "<leader>ar", M.improve, { desc = "Improve Code", silent = true })
  vim.keymap.set("n", "<leader>af", M.fix, { desc = "Fix Bugs", silent = true })
  vim.keymap.set("n", "<leader>at", M.tests, { desc = "Generate Tests", silent = true })

  -- Keymaps (visual mode - works on selection)
  vim.keymap.set("v", "<leader>ae", ":<C-u>BenchAIExplain<CR>", { desc = "Explain Selection", silent = true })
  vim.keymap.set("v", "<leader>ar", ":<C-u>BenchAIImprove<CR>", { desc = "Improve Selection", silent = true })
  vim.keymap.set("v", "<leader>af", ":<C-u>BenchAIFix<CR>", { desc = "Fix Selection", silent = true })
  vim.keymap.set("v", "<leader>at", ":<C-u>BenchAITest<CR>", { desc = "Test Selection", silent = true })

  vim.notify("BenchAI ready - <leader>a* for commands", vim.log.levels.INFO)
end

-- Plugin definition for lazy.nvim
return {
  "benchai",
  dir = vim.fn.stdpath("config") .. "/lua/plugins",
  name = "benchai",
  config = function()
    M.setup()
  end,
}
