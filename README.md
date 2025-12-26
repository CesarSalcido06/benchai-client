# BenchAI Client

Command-line tools and IDE integrations for BenchAI - your local AI engineering assistant.

## Quick Install

```bash
git clone https://github.com/YOUR_USERNAME/benchai-client.git
cd benchai-client
./install.sh
```

## What Gets Installed

1. **CLI Tool** (`benchai`) - Terminal-based chat interface
2. **VS Code** - Continue.dev configuration
3. **Neovim** - Avante.nvim plugin configuration

## Requirements

- Python 3.8+
- `requests` library (auto-installed)
- Network access to BenchAI server (default: `192.168.0.213:8085`)

## Configuration

### Change Server URL

Set the `BENCHAI_URL` environment variable before installing:

```bash
BENCHAI_URL=http://your-server:8085 ./install.sh
```

Or set it permanently in your shell config:

```bash
echo 'export BENCHAI_URL="http://your-server:8085"' >> ~/.zshrc
```

## CLI Usage

```bash
# Check connection
benchai --status

# Ask a question
benchai "what containers are running?"

# Interactive mode
benchai -i

# Use specific model
benchai -m code "write a python function to sort a list"

# Memory operations
benchai --memory-stats
benchai --search "dark mode"

# Override URL for single command
benchai --url http://192.168.1.100:8085 "hello"
```

## VS Code (Continue.dev)

1. Install the [Continue](https://marketplace.visualstudio.com/items?itemName=Continue.continue) extension
2. Config is auto-installed to `~/.continue/config.json`
3. Press `Cmd+L` (Mac) or `Ctrl+L` (Linux/Windows) to open chat

## Neovim (Avante.nvim)

1. Plugin config installed to `~/.config/nvim/lua/plugins/benchai.lua`
2. Run `:Lazy sync` in Neovim to install dependencies
3. Keybindings:
   - `<leader>aa` - Toggle AI chat sidebar
   - Select code + `ga` - Add selection to chat
   - `<CR>` - Submit in chat
   - `<C-s>` - Submit in insert mode

## Available Models

| Model | Use Case |
|-------|----------|
| `auto` | Auto-selects best model (default) |
| `general` | General questions (Phi-3 Mini) |
| `code` | Code generation (DeepSeek 6.7B) |
| `research` | Research/analysis (Qwen2.5 7B) |
| `vision` | Image analysis (Qwen2-VL 7B) |

## API Endpoints

| Endpoint | Description |
|----------|-------------|
| `/health` | Health check |
| `/v1/chat/completions` | Chat (OpenAI-compatible) |
| `/v1/models` | List available models |
| `/v1/memory/stats` | Memory statistics |
| `/v1/memory/search?q=` | Search memories |
| `/v1/rag/search?q=` | Search indexed documents |

## Troubleshooting

### Cannot connect to server

1. Check if you're on the same network as the server
2. If remote, ensure Twingate is connected
3. Test with: `curl http://192.168.0.213:8085/health`

### Neovim plugin not loading

1. Ensure you're using LazyVim or lazy.nvim
2. Run `:Lazy sync` to install dependencies
3. Check `:Lazy` for any errors

### VS Code Continue not working

1. Ensure Continue extension is installed
2. Restart VS Code after config changes
3. Check Output panel for Continue logs

## Files

```
~/.local/bin/benchai          # CLI tool
~/.continue/config.json       # VS Code Continue config
~/.config/nvim/lua/plugins/benchai.lua  # Neovim plugin
```

## Uninstall

```bash
rm ~/.local/bin/benchai
rm ~/.continue/config.json
rm ~/.config/nvim/lua/plugins/benchai.lua
```
