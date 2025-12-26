# Debug Log - Neovim Integration Issues

## Issue #1: Infinite Generation (Dec 25, 2024)

### Problem
- Neovim Avante plugin generates text infinitely
- Doesn't stop at natural completion points
- User has to manually stop generation

### Root Cause
- `max_tokens: 4096` was too high
- Server may not be sending proper stop tokens
- Streaming doesn't properly detect [DONE] signal

### Fix Applied
```lua
max_tokens = 2048, -- Reduced from 4096
```

### Additional Notes
- "openai/auto" display is **normal** - that's the provider/model name
- Temperature: 0.7 (balanced between creative and focused)
- Timeout: 30s (prevents long hangs)

### Testing
```bash
# In Neovim:
# 1. Open file: nvim test.py
# 2. Press <leader>aa
# 3. Type: "this is a test, introduce yourself"
# 4. Press <CR>
# Should stop after reasonable response (500-2000 tokens)
```

### If Still Generating Infinitely

**Option A: Further reduce max_tokens**
```lua
max_tokens = 1024, -- Even more restrictive
```

**Option B: Use faster model (less likely to over-generate)**
```lua
model = "general", -- Phi-3 is faster and more concise
```

**Option C: Check server logs**
```bash
# On homeserver
sudo journalctl -u benchai -f

# Look for:
# - Proper [DONE] signals in streaming
# - Stop token configuration
# - Model completion behavior
```

## Previous Issues (Fixed)

### Issue #0: Neovim Hanging/Stuck
- **Fixed**: Reduced timeout 120s → 30s
- **Fixed**: Simplified provider config (removed custom vendor)
- **Fixed**: Corrected endpoint URL

## Server-Side Investigation Needed

If infinite generation persists after max_tokens reduction, check:

1. **BenchAI Router** - Does it respect max_tokens?
   ```python
   # In llm_router.py, verify max_tokens is passed to model
   ```

2. **Model Response** - Is the model sending stop tokens?
   ```bash
   # Test directly
   curl -X POST http://192.168.0.213:8085/v1/chat/completions \
     -H "Content-Type: application/json" \
     -d '{
       "model": "auto",
       "messages": [{"role": "user", "content": "say hello"}],
       "max_tokens": 50,
       "stream": true
     }'
   # Should stop after ~50 tokens
   ```

3. **Streaming Format** - Check SSE format
   - Should end with: `data: [DONE]`
   - Each chunk: `data: {"choices":[{"delta":{"content":"..."}}]}`

## Configuration Summary

Current Neovim config:
- Provider: OpenAI (standard)
- Endpoint: http://192.168.0.213:8085/v1
- Model: auto (router decides)
- Timeout: 30000ms (30 seconds)
- Temperature: 0.7
- Max Tokens: 2048 ← **REDUCED**
- Auto Suggestions: Disabled

## Next Steps

1. Test in Neovim with new max_tokens
2. If still infinite, try max_tokens=1024
3. If still infinite, switch to model="general"
4. If still infinite, investigate server-side streaming implementation

## Files Modified
- `/Users/cesar/.config/nvim/lua/plugins/benchai.lua` (local)
- `benchai-client/configs/benchai.lua` (source)
- Committed: a5149ca
