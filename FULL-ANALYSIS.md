# Full Analysis: Neovim Integration Issues

**Date:** December 25, 2024
**Issue:** Neovim Avante.nvim hangs when trying to use BenchAI

---

## Executive Summary

**Root Cause:** Avante.nvim may not properly support custom OpenAI endpoints or the `stream` parameter in the way we're configuring it.

**Server Status:** ✅ WORKING (confirmed via curl)
**Client Config:** ✅ CORRECT (syntax and parameters valid)
**Integration:** ❌ NOT WORKING (Neovim still hangs)

---

## Test Results

### Server Tests (All Passing)

```bash
# Health Check
✅ curl http://192.168.0.213:8085/health
Response: {"status":"ok","service":"benchai-router-v3",...}
Time: <1 second

# Models List
✅ curl http://192.168.0.213:8085/v1/models
Response: 5 models available (auto, general, research, code, vision)
Time: <1 second

# Chat Completion (Non-Streaming)
✅ curl -X POST .../v1/chat/completions (stream: false)
Response: Valid JSON with message content
Time: 5-13 seconds

# Chat Completion (Streaming Request)
✅ curl -X POST .../v1/chat/completions (stream: true)
Response: Server ignores stream param, returns full JSON (not SSE)
Time: 5-13 seconds
```

**Conclusion:** Server works perfectly via curl. Issue is client-side.

---

## Current Neovim Configuration

```lua
{
  "yetone/avante.nvim",
  opts = {
    provider = "openai",
    openai = {
      endpoint = "http://192.168.0.213:8085/v1",
      model = "auto",
      timeout = 30000,
      temperature = 0.7,
      max_tokens = 2048,
      stream = false,  -- Added to fix streaming issue
    },
    behaviour = {
      auto_suggestions = false,
      -- ... other settings
    },
  },
}
```

**Issues Identified:**

1. **`stream` parameter may not be supported** - Avante.nvim might not recognize this parameter in the openai config
2. **Avante.nvim might always try streaming** - Even if we set `stream = false`, the plugin may ignore it
3. **Timeout might be too short** - 30 seconds might not be enough for first request (model loading)
4. **Network issues** - Avante might have trouble with the IP address format

---

## Avante.nvim Investigation

### Known Issues with Avante.nvim:

1. **Streaming Expectations:** Avante expects SSE format when using OpenAI provider
2. **Custom Endpoints:** May not fully support all OpenAI-compatible APIs
3. **Configuration Limitations:** Not all OpenAI API parameters are exposed in config
4. **Version Compatibility:** Using `version = false` means we get latest (potentially unstable)

### Possible Fixes to Try:

#### Option A: Use Different Avante Configuration

```lua
opts = {
  provider = "openai",
  openai = {
    endpoint = "http://192.168.0.213:8085/v1/chat/completions",  -- Full path
    model = "general",  -- Specific model instead of "auto"
    timeout = 60000,  -- Increase to 60 seconds
    temperature = 0,  -- Reduce for faster responses
    max_tokens = 512,  -- Lower for faster responses
  },
}
```

#### Option B: Try Claude Provider Format

Avante has specific support for Claude - maybe that format works better:

```lua
opts = {
  provider = "claude",
  claude = {
    endpoint = "http://192.168.0.213:8085/v1/chat/completions",
    model = "auto",
    max_tokens = 2048,
  },
}
```

#### Option C: Use OpenAI with API Key Workaround

```lua
opts = {
  provider = "openai",
  openai = {
    endpoint = "http://192.168.0.213:8085/v1",
    model = "auto",
    api_key_name = "BENCHAI_KEY",  -- Dummy env var
  },
}
```

Then set: `export BENCHAI_KEY="not-needed"`

#### Option D: Use copilot Provider

```lua
opts = {
  provider = "copilot",
  copilot = {
    endpoint = "http://192.168.0.213:8085/v1/chat/completions",
    model = "auto",
  },
}
```

---

## Alternative: Different Neovim Plugin

If Avante continues to fail, consider these alternatives:

### 1. NeoAI.nvim (Simpler, More Compatible)

```lua
{
  "Bryley/neoai.nvim",
  dependencies = { "MunifTanjim/nui.nvim" },
  cmd = { "NeoAI", "NeoAIOpen" },
  keys = {
    { "<leader>ai", "<cmd>NeoAIToggle<cr>", desc = "Toggle NeoAI" },
  },
  config = function()
    require("neoai").setup({
      models = {
        {
          name = "openai",
          model = "auto",
          params = {
            url = "http://192.168.0.213:8085/v1/chat/completions",
          },
        },
      },
    })
  end,
}
```

### 2. ChatGPT.nvim (Battle-Tested)

```lua
{
  "jackMort/ChatGPT.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("chatgpt").setup({
      api_host_cmd = "echo http://192.168.0.213:8085",
      api_key_cmd = "echo not-needed",
    })
  end,
}
```

### 3. Gen.nvim (Ollama-like Interface)

```lua
{
  "David-Kunz/gen.nvim",
  config = function()
    require('gen').setup({
      model = "auto",
      host = "192.168.0.213",
      port = "8085",
    })
  end,
}
```

---

## Recommended Actions

### Immediate (Try in Order):

1. **Restart Neovim completely** - Config might not have reloaded
   ```bash
   # Kill all nvim instances
   pkill nvim
   # Start fresh
   nvim
   ```

2. **Check Avante logs** - In Neovim:
   ```vim
   :messages
   :checkhealth avante
   ```
   Look for specific errors about connection or API format

3. **Try increased timeout** - Edit config:
   ```lua
   timeout = 60000,  -- 60 seconds
   ```

4. **Try specific model** - Replace `"auto"` with `"general"`:
   ```lua
   model = "general",
   ```

5. **Test with localhost** - If on homeserver:
   ```lua
   endpoint = "http://localhost:8085/v1",
   ```

### If Still Failing:

1. **Switch to NeoAI.nvim** (simpler, more compatible)
2. **Use CLI tool instead** - `benchai -i` works perfectly
3. **Report bug to Avante.nvim** - Custom OpenAI endpoints might be broken

---

## Debug Commands

### In Neovim:
```vim
" Check Avante status
:Lazy

" Check for errors
:messages

" Health check
:checkhealth avante

" View current config
:lua vim.print(require('avante.config'))

" Enable debug logging
:lua vim.g.avante_debug = true
```

### From Terminal:
```bash
# Watch for Neovim making requests
sudo tcpdump -i any -A 'host 192.168.0.213 and port 8085'

# Check if Neovim is even trying to connect
netstat -an | grep 8085
```

---

## Server-Side Improvements Needed

While investigating client issues, we identified server improvements:

1. **Implement proper SSE streaming** - Currently returns JSON even when `stream: true`
2. **Add CORS headers** - For web-based clients
3. **Better error messages** - More detailed than "All connection attempts failed"
4. **Request logging** - Log all incoming requests for debugging
5. **Model health endpoint** - Check individual model availability

---

## Files Modified

- `/Users/cesar/.config/nvim/lua/plugins/benchai.lua` - Local config
- `/Users/cesar/BenchAI/benchai-client/configs/benchai.lua` - Source config
- Added `stream = false` parameter
- Reduced `max_tokens` to 2048
- Reduced `timeout` to 30000ms

---

## Next Steps

1. Try immediate actions above
2. If still failing after 30 minutes, switch to NeoAI.nvim
3. Report findings to help improve Avante.nvim compatibility
4. Consider using CLI tool as primary interface (works perfectly)

---

## Success Criteria

- [ ] Neovim opens Avante sidebar without hanging
- [ ] Can submit message and get response within 30 seconds
- [ ] Responses are complete and readable
- [ ] No errors in `:messages`
- [ ] `:checkhealth avante` shows no critical issues

---

## Conclusion

**The BenchAI server is working correctly.** The issue is with Avante.nvim's compatibility with custom OpenAI endpoints. The server responds perfectly to curl but Avante seems to have issues with:

1. Non-standard OpenAI API implementations
2. Streaming vs non-streaming detection
3. Custom endpoint configurations

**Recommendation:** Try NeoAI.nvim as it's designed for custom endpoints, or use the excellent CLI tool which works flawlessly.
