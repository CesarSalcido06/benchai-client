# BenchAI Client Tools

CLI, VS Code, and Neovim integrations for BenchAI.

## Quick Install

```bash
cd benchai-client
./install.sh
```

Installs:
- **CLI tool** - `benchai` command with streaming support
- **VS Code** - Continue.dev configuration
- **Neovim** - Avante.nvim plugin setup

## Requirements

- Python 3.8+
- BenchAI server running and accessible
- Default server: `http://192.168.0.213:8085`

## Configuration

### Custom Server URL

**Before installation:**
```bash
BENCHAI_URL=http://your-server:8085 ./install.sh
```

**Permanent (in shell config):**
```bash
echo 'export BENCHAI_URL="http://your-server:8085"' >> ~/.zshrc
source ~/.zshrc
```

**Per-command override:**
```bash
benchai --url http://localhost:8085 "your query"
```

## CLI Usage

### Basic Commands
```bash
# Check server status
benchai --status

# Simple query
benchai "explain async/await in Python"

# Streaming response
benchai --stream "write a binary search function"

# Interactive mode
benchai -i

# Interactive with streaming
benchai -i --stream
```

### Model Selection
```bash
benchai -m general "what's the weather?"
benchai -m code "write a quicksort implementation"
benchai -m research "explain quantum computing"
benchai -m vision "analyze this image"
```

### Memory Features
```bash
# View memory stats
benchai --memory-stats

# Search memories
benchai --search "python preferences"
```

### Interactive Mode Commands
When in `benchai -i`:
- Type your message to chat
- `status` - Check server health
- `stream` - Toggle streaming on/off
- `exit` or `quit` - Exit chat

## VS Code (Continue.dev)

### Setup
1. Install [Continue extension](https://marketplace.visualstudio.com/items?itemName=Continue.continue)
2. Configuration auto-installed to `~/.continue/config.json`
3. Restart VS Code

### Usage
- **Open chat**: `Cmd+L` (Mac) or `Ctrl+L` (Windows/Linux)
- **Inline chat**: `Cmd+I` - Edit code inline
- **Tab autocomplete**: Automatic code suggestions

### Available Models in Continue
- BenchAI Auto (default routing)
- BenchAI Code (optimized for coding)
- BenchAI Research (for analysis)

## Neovim (Avante.nvim)

### Setup
1. Config installed to `~/.config/nvim/lua/plugins/benchai.lua`
2. Run `:Lazy sync` to install dependencies
3. Restart Neovim

### Keybindings
| Key | Action |
|-----|--------|
| `<leader>aa` | Toggle AI chat sidebar |
| `ga` (visual mode) | Add selection to chat |
| `<CR>` | Submit message (normal mode) |
| `<C-s>` | Submit message (insert mode) |
| `co` | Accept "ours" in diff |
| `ct` | Accept "theirs" in diff |
| `]]` | Jump to next change |
| `[[` | Jump to previous change |

## Models

All clients support these models:

| Model | Use Case | Backend |
|-------|----------|---------|
| `auto` | Auto-routing (default) | Smart selection |
| `general` | Quick answers | Phi-3 Mini |
| `code` | Programming tasks | DeepSeek Coder |
| `research` | Deep analysis | Qwen2.5 7B |
| `vision` | Image understanding | Qwen2-VL |

## Troubleshooting

### Cannot connect to server
```bash
# Test connection
curl http://192.168.0.213:8085/health

# Check with CLI
benchai --status
```

**Solutions:**
- Verify BenchAI server is running
- Ensure you're on the same network
- Check firewall settings
- Try `--url http://localhost:8085` if running locally

### CLI command not found
```bash
# Check PATH
echo $PATH | grep ".local/bin"

# Add to PATH if missing
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### VS Code Continue issues
1. Verify extension is installed
2. Check `~/.continue/config.json` exists
3. Restart VS Code
4. Check Output → Continue for errors

### Neovim plugin not loading
```vim
:checkhealth avante
:Lazy sync
:Lazy log
```

**Requirements:**
- LazyVim or lazy.nvim plugin manager
- Neovim 0.9+

## Installed Files

```
~/.local/bin/benchai                      # CLI executable
~/.continue/config.json                   # VS Code config
~/.config/nvim/lua/plugins/benchai.lua    # Neovim plugin
```

## Uninstall

```bash
rm ~/.local/bin/benchai
rm ~/.continue/config.json
rm ~/.config/nvim/lua/plugins/benchai.lua
```

## Testing

See [TESTING.md](TESTING.md) for comprehensive testing guide.

## Support

- **Server Issues**: See [benchai/docs/TROUBLESHOOTING.md](../benchai/docs/TROUBLESHOOTING.md)
- **API Reference**: See [benchai/docs/API.md](../benchai/docs/API.md)
- **Report Bugs**: Open an issue on GitHub
