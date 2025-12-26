# Neovim Integration Hotfix Guide

## Issue: Neovim Getting Stuck

If Neovim freezes when using Avante.nvim with BenchAI, follow these steps.

## Quick Fix

### Option 1: Update Existing Config

```bash
# On your homeserver after pulling
cd ~/.config/nvim/lua/plugins
cp ~/BenchAI/benchai-client/configs/benchai.lua benchai.lua

# Restart Neovim and run
nvim
:Lazy sync
:Lazy reload avante.nvim
```

### Option 2: Manual Update

Edit `~/.config/nvim/lua/plugins/benchai.lua`:

**Replace the `opts` section with:**

```lua
opts = {
  -- Use OpenAI provider (most stable)
  provider = "openai",
  auto_suggestions_provider = "openai",

  openai = {
    endpoint = "http://192.168.0.213:8085/v1",
    model = "auto",
    timeout = 30000, -- 30 seconds
    temperature = 0.7,
    max_tokens = 4096,
  },

  -- Disable auto_suggestions to prevent hangs
  behaviour = {
    auto_suggestions = false,
    auto_set_highlight_group = true,
    auto_set_keymaps = true,
    auto_apply_diff_after_generation = false,
    support_paste_from_clipboard = true,
  },

  -- ... rest of config
},
```

## What Changed

### 1. Removed Custom Vendor Configuration
- **Before:** Used custom `vendors.benchai` setup
- **After:** Use standard `openai` provider
- **Why:** Custom vendors can cause compatibility issues

### 2. Fixed Endpoint URL
- **Before:** `http://192.168.0.213:8085/v1/chat/completions`
- **After:** `http://192.168.0.213:8085/v1`
- **Why:** Provider adds `/chat/completions` automatically

### 3. Reduced Timeout
- **Before:** 120000ms (2 minutes)
- **After:** 30000ms (30 seconds)
- **Why:** Prevents long hangs, fails faster

### 4. Confirmed Auto-suggestions Disabled
- **Setting:** `auto_suggestions = false`
- **Why:** Auto-suggestions can cause constant API calls and hangs

## Troubleshooting Steps

### 1. Check Avante.nvim Health
```vim
:checkhealth avante
```

Look for errors related to:
- Missing dependencies
- Node.js version
- API connection

### 2. Check Logs
```vim
:messages
```

Look for error messages from Avante.

### 3. Test Connection from Neovim
```vim
:lua vim.notify(vim.inspect(require('avante.config')))
```

This shows the current configuration.

### 4. Manual API Test
From terminal on homeserver:
```bash
curl -X POST http://192.168.0.213:8085/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "auto",
    "messages": [{"role": "user", "content": "test"}],
    "stream": false
  }'
```

Should return JSON response quickly.

## Common Issues

### Issue: Still Hangs on First Request

**Solution 1: Clear cache**
```bash
rm -rf ~/.local/share/nvim/avante
rm -rf ~/.cache/nvim/avante
nvim
:Lazy clean
:Lazy sync
```

**Solution 2: Check network**
```bash
# From homeserver
ping 192.168.0.213
curl http://192.168.0.213:8085/health
```

### Issue: "Connection refused"

**Check BenchAI is running:**
```bash
sudo systemctl status benchai
curl http://localhost:8085/health
```

**Check firewall:**
```bash
sudo ufw status
# Should allow port 8085
```

### Issue: "Timeout" errors

**Reduce timeout further:**
```lua
openai = {
  endpoint = "http://192.168.0.213:8085/v1",
  model = "auto",
  timeout = 15000, -- Try 15 seconds
  -- ...
},
```

### Issue: Works but slow responses

**Use faster model:**
```lua
openai = {
  endpoint = "http://192.168.0.213:8085/v1",
  model = "general", -- Phi-3 is fastest
  -- ...
},
```

## Testing the Fix

1. **Restart Neovim** completely (quit all instances)

2. **Sync plugins:**
   ```vim
   :Lazy sync
   ```

3. **Open a code file:**
   ```bash
   nvim test.py
   ```

4. **Test toggle sidebar:**
   Press `<leader>aa` (usually `<space>aa`)

   - Should open sidebar without hanging
   - May take 2-3 seconds first time

5. **Test simple prompt:**
   - Type: "hello"
   - Press `<CR>` to submit
   - Should get response in 5-10 seconds

6. **Test code assistance:**
   - Select some code (visual mode: `V`)
   - Press `ga` to add to chat
   - Ask: "explain this"
   - Press `<CR>`
   - Should get explanation

## If Still Having Issues

### Fallback 1: Use Localhost (if on homeserver)

```lua
openai = {
  endpoint = "http://localhost:8085/v1",
  model = "auto",
  timeout = 30000,
  -- ...
},
```

### Fallback 2: Disable Avante, Use Alternative

If Avante continues to have issues, consider alternative Neovim AI plugins:

**Option A: NeoAI.nvim**
```lua
{
  "Bryley/neoai.nvim",
  dependencies = { "MunifTanjim/nui.nvim" },
  cmd = {
    "NeoAI",
    "NeoAIOpen",
    "NeoAIClose",
    "NeoAIToggle",
  },
  keys = {
    { "<leader>as", desc = "summarize text" },
    { "<leader>ag", desc = "generate git message" },
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

**Option B: Just use the CLI**
The CLI tool works perfectly:
```bash
benchai -i --stream
```

## Verification Checklist

After applying fix:

- [ ] Neovim starts without errors
- [ ] `:Lazy` shows avante.nvim loaded (green checkmark)
- [ ] `<leader>aa` opens sidebar (may take 2-3s first time)
- [ ] Can submit messages without hanging
- [ ] Responses appear (within 30s timeout)
- [ ] No error messages in `:messages`
- [ ] `:checkhealth avante` shows no critical errors

## Need Help?

1. Check `:messages` for specific error
2. Run `:checkhealth avante`
3. Test CLI: `benchai --status`
4. Check server: `curl http://192.168.0.213:8085/health`
5. Review server logs: `sudo journalctl -u benchai -f`

## Updated Files in This Fix

- `benchai-client/configs/benchai.lua` - Main fix
- `benchai-client/configs/benchai-fixed.lua` - Backup copy
- `NVIM-HOTFIX.md` - This guide

Pull these changes and reinstall:
```bash
cd ~/BenchAI
git pull
cd benchai-client
./install.sh
```
