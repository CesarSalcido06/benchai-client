#!/bin/bash
#
# BenchAI Client Installer
# Installs CLI tool and configures IDE integrations
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BENCHAI_URL="${BENCHAI_URL:-http://192.168.0.213:8085}"
NVIM_PLUGIN="${NVIM_PLUGIN:-simple}"  # Options: simple (default), neoai, avante

echo "================================"
echo "  BenchAI Client Installer"
echo "================================"
echo ""
echo "Server URL: $BENCHAI_URL"
echo "Neovim Plugin: $NVIM_PLUGIN"
echo ""

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    SHELL_RC="$HOME/.zshrc"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    SHELL_RC="$HOME/.bashrc"
    [[ -f "$HOME/.zshrc" ]] && SHELL_RC="$HOME/.zshrc"
else
    OS="unknown"
    SHELL_RC="$HOME/.bashrc"
fi

echo "Detected OS: $OS"
echo "Shell config: $SHELL_RC"
echo ""

# Function to install CLI
install_cli() {
    echo "[1/4] Installing CLI tool..."

    # Check for Python
    if ! command -v python3 &> /dev/null; then
        echo "Error: Python 3 is required. Please install it first."
        exit 1
    fi

    # Install requests if needed
    python3 -c "import requests" 2>/dev/null || {
        echo "Installing requests library..."
        pip3 install --user requests
    }

    # Create bin directory
    mkdir -p "$HOME/.local/bin"

    # Copy CLI script
    cp "$SCRIPT_DIR/benchai" "$HOME/.local/bin/benchai"
    chmod +x "$HOME/.local/bin/benchai"

    # Add to PATH if not already there
    if ! grep -q '.local/bin' "$SHELL_RC" 2>/dev/null; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
        echo "Added ~/.local/bin to PATH in $SHELL_RC"
    fi

    echo "CLI installed to ~/.local/bin/benchai"
}

# Function to configure Continue.dev (VS Code)
configure_continue() {
    echo "[2/4] Configuring Continue.dev for VS Code..."

    mkdir -p "$HOME/.continue"

    cat > "$HOME/.continue/config.json" << EOF
{
  "models": [
    {
      "title": "BenchAI Auto",
      "provider": "openai",
      "model": "auto",
      "apiKey": "not-needed",
      "apiBase": "${BENCHAI_URL}/v1",
      "requestOptions": {
        "timeout": 120000,
        "verifySsl": false
      }
    },
    {
      "title": "BenchAI Code",
      "provider": "openai",
      "model": "code",
      "apiKey": "not-needed",
      "apiBase": "${BENCHAI_URL}/v1",
      "requestOptions": {
        "timeout": 120000,
        "verifySsl": false
      }
    },
    {
      "title": "BenchAI Research",
      "provider": "openai",
      "model": "research",
      "apiKey": "not-needed",
      "apiBase": "${BENCHAI_URL}/v1",
      "requestOptions": {
        "timeout": 120000,
        "verifySsl": false
      }
    }
  ],
  "tabAutocompleteModel": {
    "title": "BenchAI Code Autocomplete",
    "provider": "openai",
    "model": "code",
    "apiKey": "not-needed",
    "apiBase": "${BENCHAI_URL}/v1",
    "requestOptions": {
      "timeout": 30000,
      "verifySsl": false
    }
  },
  "embeddingsProvider": {
    "provider": "openai",
    "model": "auto",
    "apiKey": "not-needed",
    "apiBase": "${BENCHAI_URL}/v1"
  },
  "allowAnonymousTelemetry": false,
  "completionOptions": {
    "maxTokens": 4096,
    "temperature": 0.7
  },
  "tabAutocompleteOptions": {
    "maxPromptTokens": 1024,
    "debounceDelay": 500,
    "maxSuffixPercentage": 0.5
  }
}
EOF

    echo "Continue.dev configured at ~/.continue/config.json"
    echo "Install the Continue extension: https://marketplace.visualstudio.com/items?itemName=Continue.continue"
    echo "Press Cmd+L (Mac) or Ctrl+L (Linux/Windows) to start chatting"
}

# Function to configure Neovim
configure_neovim() {
    echo "[3/4] Configuring Neovim..."

    NVIM_PLUGIN_DIR="$HOME/.config/nvim/lua/plugins"

    if [[ -d "$HOME/.config/nvim" ]]; then
        mkdir -p "$NVIM_PLUGIN_DIR"

        # Choose plugin based on NVIM_PLUGIN env var
        if [[ "$NVIM_PLUGIN" == "avante" ]]; then
            echo "Installing Avante.nvim (legacy - may have issues)..."
            SOURCE_FILE="$SCRIPT_DIR/configs/benchai.lua"
        elif [[ "$NVIM_PLUGIN" == "neoai" ]]; then
            echo "Installing NeoAI.nvim..."
            SOURCE_FILE="$SCRIPT_DIR/configs/benchai-neoai.lua"
        else
            echo "Installing BenchAI Simple (recommended - no dependencies)..."
            SOURCE_FILE="$SCRIPT_DIR/configs/benchai-simple.lua"
        fi

        # Copy config and replace URL
        sed "s|http://192.168.0.213:8085|${BENCHAI_URL}|g" "$SOURCE_FILE" > "$NVIM_PLUGIN_DIR/benchai.lua"

        echo "Neovim plugin installed to $NVIM_PLUGIN_DIR/benchai.lua"

        if [[ "$NVIM_PLUGIN" == "simple" ]] || [[ "$NVIM_PLUGIN" == "" ]]; then
            echo "No plugin dependencies - just restart Neovim!"
        else
            echo "Run :Lazy sync in Neovim to install dependencies"
        fi
        echo ""
        echo "Keybindings:"
        if [[ "$NVIM_PLUGIN" == "avante" ]]; then
            echo "  <leader>aa - Toggle AI chat sidebar"
            echo "  Select code + ga - Add selection to chat"
        else
            echo "  <leader>aa - Ask BenchAI (input prompt)"
            echo "  <leader>ae - Explain code"
            echo "  <leader>ar - Improve/refactor code"
            echo "  <leader>af - Find and fix bugs"
            echo "  <leader>at - Generate tests"
            echo "  (Works in normal mode on paragraph, visual mode on selection)"
        fi
    else
        echo "Neovim config not found, skipping..."
        echo "To install later, copy configs/benchai-simple.lua to ~/.config/nvim/lua/plugins/benchai.lua"
    fi
}

# Function to setup environment variables
setup_environment() {
    echo "[3.5/4] Setting up environment variables..."

    # Add BenchAI environment variables for NeoAI and other tools
    if ! grep -q 'OPENAI_API_BASE' "$SHELL_RC" 2>/dev/null; then
        cat >> "$SHELL_RC" << EOF

# BenchAI Configuration
export BENCHAI_URL="${BENCHAI_URL}"
export OPENAI_API_BASE="${BENCHAI_URL}/v1"
export OPENAI_API_KEY="not-needed"
EOF
        echo "Added BenchAI environment variables to $SHELL_RC"
    else
        echo "Environment variables already configured"
    fi
}

# Function to test connection
test_connection() {
    echo "[4/4] Testing connection to BenchAI..."

    if curl -s --connect-timeout 5 "$BENCHAI_URL/health" > /dev/null 2>&1; then
        echo "Connection successful!"
        curl -s "$BENCHAI_URL/health" | python3 -c "import sys,json; d=json.load(sys.stdin); print(f'  Status: {d.get(\"status\")}'); print(f'  Service: {d.get(\"service\")}')" 2>/dev/null || true
    else
        echo "Warning: Cannot connect to $BENCHAI_URL"
        echo "Make sure you're on the same network or connected via Twingate"
    fi
}

# Main installation
echo "Starting installation..."
echo ""

install_cli
echo ""

configure_continue
echo ""

configure_neovim
echo ""

setup_environment
echo ""

test_connection
echo ""

echo "================================"
echo "  Installation Complete!"
echo "================================"
echo ""
echo "Usage:"
echo "  benchai --status              # Check connection"
echo "  benchai \"your question\"       # Ask a question"
echo "  benchai -i                    # Interactive mode"
echo ""
echo "VS Code: Press Cmd+L (Mac) or Ctrl+L to open Continue chat"
echo ""
if [[ "$NVIM_PLUGIN" == "avante" ]]; then
    echo "Neovim (Avante): Run :Lazy sync, then use <leader>aa"
elif [[ "$NVIM_PLUGIN" == "neoai" ]]; then
    echo "Neovim (NeoAI): Run :Lazy sync, then use <leader>aa"
else
    echo "Neovim (BenchAI Simple): Just restart Neovim!"
    echo "  Keybindings:"
    echo "    <leader>aa - Ask BenchAI"
    echo "    <leader>ae - Explain code"
    echo "    <leader>ar - Improve code"
    echo "    <leader>af - Fix bugs"
    echo "    <leader>at - Generate tests"
fi
echo ""
echo "IMPORTANT: Restart your terminal or run: source $SHELL_RC"
echo ""
echo "To switch Neovim plugin:"
echo "  ./install.sh                     # BenchAI Simple (default, no deps)"
echo "  NVIM_PLUGIN=neoai ./install.sh   # NeoAI (requires plugin install)"
echo "  NVIM_PLUGIN=avante ./install.sh  # Avante (legacy, may have issues)"
