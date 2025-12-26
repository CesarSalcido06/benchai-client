#!/bin/bash
#
# BenchAI Client Installer
# Installs CLI tool and configures IDE integrations
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BENCHAI_URL="${BENCHAI_URL:-http://192.168.0.213:8085}"

echo "================================"
echo "  BenchAI Client Installer"
echo "================================"
echo ""
echo "Server URL: $BENCHAI_URL"
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
  "models": [{
    "title": "BenchAI",
    "provider": "openai",
    "model": "auto",
    "apiKey": "not-needed",
    "apiBase": "${BENCHAI_URL}/v1",
    "requestOptions": {"timeout": 120000}
  }],
  "tabAutocompleteModel": {
    "title": "BenchAI Code",
    "provider": "openai",
    "model": "code",
    "apiKey": "not-needed",
    "apiBase": "${BENCHAI_URL}/v1"
  },
  "allowAnonymousTelemetry": false
}
EOF

    echo "Continue.dev configured at ~/.continue/config.json"
    echo "Note: Install the Continue extension in VS Code"
}

# Function to configure Neovim
configure_neovim() {
    echo "[3/4] Configuring Neovim (Avante.nvim)..."

    NVIM_PLUGIN_DIR="$HOME/.config/nvim/lua/plugins"

    if [[ -d "$HOME/.config/nvim" ]]; then
        mkdir -p "$NVIM_PLUGIN_DIR"
        cp "$SCRIPT_DIR/configs/benchai.lua" "$NVIM_PLUGIN_DIR/benchai.lua"

        # Update the URL in the config
        sed -i.bak "s|http://192.168.0.213:8085|${BENCHAI_URL}|g" "$NVIM_PLUGIN_DIR/benchai.lua" 2>/dev/null || \
        sed -i '' "s|http://192.168.0.213:8085|${BENCHAI_URL}|g" "$NVIM_PLUGIN_DIR/benchai.lua"
        rm -f "$NVIM_PLUGIN_DIR/benchai.lua.bak"

        echo "Neovim plugin installed to $NVIM_PLUGIN_DIR/benchai.lua"
        echo "Run :Lazy sync in Neovim to install dependencies"
    else
        echo "Neovim config not found, skipping..."
        echo "To install later, copy configs/benchai.lua to ~/.config/nvim/lua/plugins/"
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
echo "Neovim:  Run :Lazy sync, then use <leader>aa for AI chat"
echo ""
echo "Restart your terminal or run: source $SHELL_RC"
