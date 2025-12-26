# BenchAI Client Testing Guide

This guide will help you test all BenchAI client integrations to ensure everything is working properly.

## Prerequisites

1. BenchAI server must be running on your homeserver
2. You must be on the same network (or connected via Twingate)
3. The server should be accessible at `http://192.168.0.213:8085`

## Test 1: CLI Installation

### 1.1 Run the installer
```bash
cd benchai-client
./install.sh
```

**Expected Output:**
- ✓ Python 3 detected
- ✓ CLI installed to ~/.local/bin/benchai
- ✓ Continue.dev configured
- ✓ Neovim plugin installed (if nvim config exists)
- ✓ Connection test passes

### 1.2 Reload your shell
```bash
source ~/.zshrc  # or ~/.bashrc
```

## Test 2: CLI Basic Functions

### 2.1 Check server status
```bash
benchai --status
```

**Expected Output:**
```
BenchAI Status
Status:  healthy
Service: BenchAI Router
URL:     http://192.168.0.213:8085

Features:
  ✓ planner
  ✓ memory
  ✓ rag
  ✓ tts
```

### 2.2 Simple query
```bash
benchai "what is 2+2?"
```

**Expected Output:**
- Clear response: "4" or "2+2 equals 4"
- No error messages

### 2.3 Streaming mode
```bash
benchai --stream "tell me a short joke"
```

**Expected Output:**
- Text appears word-by-word in real-time
- Colored output showing "BenchAI:" prefix

### 2.4 Model selection
```bash
benchai -m code "write a python function to add two numbers"
```

**Expected Output:**
- Python function code
- Proper syntax highlighting context

## Test 3: CLI Interactive Mode

### 3.1 Basic interactive mode
```bash
benchai -i
```

**Expected Output:**
- Welcome banner with box drawing characters
- Shows connected URL
- Displays available commands

**Test Commands:**
1. Type `status` - should show health status
2. Type `stream` - should toggle streaming
3. Ask a question - should get response
4. Type `exit` - should exit cleanly

### 3.2 Interactive with streaming
```bash
benchai -i --stream
```

**Expected Output:**
- Same as above but "Streaming: Enabled"
- Responses stream in real-time

## Test 4: CLI Memory Features

### 4.1 Memory statistics
```bash
benchai --memory-stats
```

**Expected Output:**
```
Memory Statistics
Total memories: X
FTS5 search:    ✓ Enabled

By Category:
  preference: X
  fact: X
```

### 4.2 Memory search
```bash
benchai --search "test"
```

**Expected Output:**
- List of memories containing "test"
- Or "No memories found" if none exist

## Test 5: VS Code Continue Integration

### 5.1 Install Continue extension
1. Open VS Code
2. Go to Extensions (Cmd+Shift+X)
3. Search for "Continue"
4. Install "Continue - Codestral, Claude, and more"

### 5.2 Verify configuration
1. Check that `~/.continue/config.json` exists
2. Verify it contains BenchAI endpoints

```bash
cat ~/.continue/config.json | grep -A 2 "BenchAI"
```

### 5.3 Test chat
1. Press `Cmd+L` (Mac) or `Ctrl+L` (Linux/Windows)
2. Continue sidebar should open on the right
3. Select "BenchAI Auto" from model dropdown
4. Type: "Hello, can you help me code?"

**Expected Output:**
- Response appears in chat
- No connection errors

### 5.4 Test code completion
1. Create a new Python file
2. Type: `def add_numbers(`
3. Wait for suggestion

**Expected Output:**
- Autocomplete suggestions appear
- Uses "BenchAI Code" model

### 5.5 Test inline chat
1. Highlight some code
2. Press `Cmd+I` (inline chat)
3. Ask: "explain this code"

**Expected Output:**
- Explanation appears inline
- Can accept/reject changes

## Test 6: Neovim Avante Integration

### 6.1 Install dependencies (if not already done)
```bash
nvim
```
Then run:
```vim
:Lazy sync
```

### 6.2 Check plugin loaded
```vim
:Lazy
```

**Expected Output:**
- "avante.nvim" should be in the list
- Status should be "loaded" (green checkmark)

### 6.3 Test AI chat sidebar
1. In Neovim, press `<leader>aa` (usually space + aa)
2. Chat sidebar should open on the right

**Expected Output:**
- Sidebar opens with chat interface
- No error messages

### 6.4 Test code assistance
1. Open a code file
2. Select some lines (visual mode: `V`)
3. Press `ga` to add selection to chat
4. Type: "explain this code"
5. Press `<CR>` to submit

**Expected Output:**
- Response appears in sidebar
- Code remains selected

### 6.5 Test mappings
Test these keybindings:
- `<leader>aa` - Toggle chat sidebar ✓
- `<CR>` in chat - Submit message ✓
- `<C-s>` in insert mode - Submit ✓
- `]]` - Jump to next change ✓
- `[[` - Jump to previous change ✓

### 6.6 Test diff acceptance
1. Ask AI to modify code
2. AI generates diff
3. Press `co` - Accept "ours"
4. Press `ct` - Accept "theirs"

**Expected Output:**
- Changes apply correctly
- No buffer errors

## Test 7: Error Handling

### 7.1 Test with server down
1. Stop BenchAI server (or disconnect from network)
2. Run: `benchai --status`

**Expected Output:**
```
✗ Cannot connect to BenchAI at http://192.168.0.213:8085
  Make sure the server is running and you're on the same network
```

### 7.2 Test with wrong URL
```bash
benchai --url http://invalid:9999 "test"
```

**Expected Output:**
- Clear error message about connection failure
- No stack traces or cryptic errors

### 7.3 Test timeout
```bash
# This should timeout gracefully if server is slow
benchai "very complex query that might take too long"
```

**Expected Output:**
- Either completes within 120 seconds
- Or shows timeout error message

## Test 8: Custom URL Configuration

### 8.1 Environment variable
```bash
export BENCHAI_URL="http://localhost:8085"
benchai --status
```

**Expected Output:**
- Connects to localhost instead of 192.168.0.213
- Status shows new URL

### 8.2 Command line override
```bash
benchai --url http://192.168.1.100:8085 --status
```

**Expected Output:**
- Connects to specified URL
- Status shows custom URL

## Test 9: Advanced Features

### 9.1 Test all models
```bash
benchai -m general "what's the weather?"
benchai -m code "write a sorting function"
benchai -m research "explain quantum computing"
```

**Expected Output:**
- Each uses appropriate model
- Responses match model specialty

### 9.2 Test long conversation (interactive)
```bash
benchai -i
```
1. Ask: "remember my name is Alice"
2. Ask: "what's my name?"

**Expected Output:**
- Should remember context within session
- Should recall name

## Troubleshooting

### CLI not found
```bash
echo $PATH | grep ".local/bin"
```
If not found, add to your shell config:
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Continue.dev not working
1. Restart VS Code
2. Check Output panel: View → Output → Continue
3. Look for connection errors

### Neovim plugin errors
```vim
:checkhealth avante
:Lazy log
```

### Color output issues
If colors don't appear in CLI:
- Check terminal supports ANSI colors
- Try different terminal emulator

## Success Criteria

✓ All CLI commands work without errors
✓ Status check shows "healthy"
✓ Interactive mode works with and without streaming
✓ VS Code Continue extension connects and responds
✓ Neovim Avante plugin loads and responds
✓ All keybindings work as expected
✓ Error messages are clear and helpful
✓ Memory features work correctly

## Reporting Issues

If any test fails:

1. Note which test failed
2. Copy exact error message
3. Check server logs if available
4. Verify network connectivity
5. Try with `--url http://localhost:8085` if on same machine

## Next Steps

Once all tests pass:

1. Customize keybindings in Neovim config if desired
2. Set up shell aliases for common commands
3. Explore the 88+ tools available through BenchAI
4. Configure persistent memory categories
5. Index your codebase for RAG search

Happy coding with BenchAI! 🚀
