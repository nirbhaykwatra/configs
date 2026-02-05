#!/bin/bash

################################################################################
# Ubuntu 25.10 WSL Development Environment Setup Script
################################################################################
# This script automates the installation and configuration of development tools
# and utilities for an Ubuntu 25.10 WSL instance.
# 
# IMPORTANT: zsh and oh-my-zsh are installed FIRST, and all subsequent
# configurations are set up for zsh as the primary shell.
# 
# Usage: bash setup-env.sh
# 
# Note: This script requires sudo access and will prompt for password if needed.
################################################################################

set -e  # Exit immediately if any command exits with a non-zero status

# Determine the actual user (handles both sudo and non-sudo execution)
if [ -n "$SUDO_USER" ]; then
    ACTUAL_USER="$SUDO_USER"
    ACTUAL_HOME=$(eval echo ~"$SUDO_USER")
else
    ACTUAL_USER="$USER"
    ACTUAL_HOME="$HOME"
fi

# Color codes for output messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

################################################################################
# Helper Functions
################################################################################

# Print colored header for each section
print_header() {
    echo -e "\n${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}\n"
}

# Print success message
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Print error message
print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Print info message
print_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

# Function to safely append to zshrc and bashrc without duplicates
# Compatible with both direct execution and sudo execution
add_to_shell_configs() {
    local config_line="$1"
    local section_name="$2"
    
    # Add to zshrc
    if ! grep -Fxq "$config_line" "$ACTUAL_HOME/.zshrc" 2>/dev/null; then
        echo "" >> "$ACTUAL_HOME/.zshrc"
        echo "# $section_name" >> "$ACTUAL_HOME/.zshrc"
        echo "$config_line" >> "$ACTUAL_HOME/.zshrc"
    fi
    
    # Add to bashrc
    if ! grep -Fxq "$config_line" "$ACTUAL_HOME/.bashrc" 2>/dev/null; then
        echo "" >> "$ACTUAL_HOME/.bashrc"
        echo "# $section_name" >> "$ACTUAL_HOME/.bashrc"
        echo "$config_line" >> "$ACTUAL_HOME/.bashrc"
    fi
}
################################################################################
# Setup $ACTUAL_HOME/.bin in PATH
################################################################################

# Create .bin directory if it doesn't exist
if [ ! -d "$ACTUAL_HOME/.bin" ]; then
    mkdir -p "$ACTUAL_HOME/.bin"
    chown "$ACTUAL_USER:$ACTUAL_USER" "$ACTUAL_HOME/.bin"
fi

# Add $ACTUAL_HOME/.bin to PATH if not already present
if [[ ":$PATH:" != *":$ACTUAL_HOME/.bin:"* ]]; then
    export PATH="$ACTUAL_HOME/.bin:$PATH"
fi

################################################################################
# System Update
################################################################################

print_header "Updating System Packages"
# Update package manager cache and upgrade all packages
sudo apt-get update -y
sudo apt-get upgrade -y
print_success "System packages updated"

################################################################################
# Pre-requisite: unzip
################################################################################

# unzip: Utility for extracting .zip files (needed as dependency for oh-my-posh font extraction)
sudo apt-get install -y unzip
print_success "unzip installed"

################################################################################
# Zsh and Oh-My-Zsh - INSTALLED FIRST
################################################################################

print_header "Installing Zsh and Oh-My-Zsh (PRIORITY INSTALLATION)"

# Install zsh: Modern shell with better defaults and plugin support
sudo apt-get install -y zsh
print_success "zsh installed"

# Install curl (needed for oh-my-zsh installer, and also a required package)
sudo apt-get install -y curl
print_success "curl installed"

# Install oh-my-zsh using the official installer in unattended mode
# This will create ~/.zshrc automatically
if [ ! -d "$ACTUAL_HOME/.oh-my-zsh" ]; then
    print_info "Installing Oh-My-Zsh..."
    # Use RUNZSH=no to prevent automatic shell switching during installation
    sudo -u "$ACTUAL_USER" bash -c 'RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'
    chown -R "$ACTUAL_USER:$ACTUAL_USER" "$ACTUAL_HOME/.oh-my-zsh"
    print_success "Oh-My-Zsh installed"
else
    print_info "Oh-My-Zsh already installed"
fi

# Change default shell to zsh immediately
print_info "Changing default shell to zsh..."
sudo chsh -s $(which zsh) "$ACTUAL_USER"
print_success "Default shell changed to zsh"


print_success "Zsh environment ready for configuration"

################################################################################
# Oh-My-Posh - Prompt Theme Engine
################################################################################

print_header "Installing Oh-My-Posh (Prompt Theme Engine)"

# oh-my-posh: A theme engine for any shell that can display git status,
# execution time, exit codes, and more in a beautiful and customizable way
# It works alongside oh-my-zsh for an enhanced shell experience
mkdir -p "$ACTUAL_HOME/.bin"
chown "$ACTUAL_USER:$ACTUAL_USER" "$ACTUAL_HOME/.bin"

if ! command -v oh-my-posh &> /dev/null; then
    print_info "Installing oh-my-posh..."
    # Download and install oh-my-posh using the official installer
    curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$ACTUAL_HOME/.bin"
    print_success "oh-my-posh installed successfully"
else
    print_info "oh-my-posh already installed"
fi

# Configure oh-my-posh in shell configs
# Available themes can be viewed with: oh-my-posh config show
add_to_shell_configs 'eval "$(oh-my-posh init zsh --config ~/.configs/nirbhaykwatra.omp.json)"' "oh-my-posh initialization"

# Note about terminal font configuration:
print_info "Note: For icons and symbols to display correctly, your terminal must use a Nerd Font"
print_info "Configure your terminal to use '0xProto Nerd Font' in its settings"

print_success "Oh-My-Posh configured in zshrc"

# Install a Nerd Font for proper icon and symbol display
# 0xProto is a monospace font designed for coding with excellent readability
print_header "Installing 0xProto Nerd Font for Oh-My-Posh"
oh-my-posh font install 0xProto
print_success "0xProto Nerd Font installed"

# Download custom oh-my-posh theme configuration
print_info "Downloading oh-my-posh theme configuration..."
if [ ! -d "$ACTUAL_HOME/.configs" ]; then
    print_info "Cloning configs repo..."
    git clone https://github.com/nirbhaykwatra/configs.git "$ACTUAL_HOME/.configs"
    chown -R "$ACTUAL_USER:$ACTUAL_USER" "$ACTUAL_HOME/.configs"
    print_success "Configs repo cloned successfully"
else
    print_info "Configs repo already exists, skipping cloning"
fi

################################################################################
# Essential Build Tools and Utilities
################################################################################

print_header "Installing Build Tools and Essential Utilities"

# build-essential: Compiler and development libraries needed for compiling software
sudo apt-get install -y build-essential
print_success "build-essential installed"

# wget: Non-interactive network downloader
sudo apt-get install -y wget
print_success "wget installed"

# htop: Interactive process viewer (better alternative to 'top')
sudo apt-get install -y htop
print_success "htop installed"

# git: Version control system (usually pre-installed, but ensure it's available)
sudo apt-get install -y git
print_success "git installed"

################################################################################
# Text Editors and Development Tools
################################################################################

print_header "Installing Text Editors and Development Tools"

# neovim: Modern vim-based text editor with better defaults
sudo apt-get install -y neovim
print_success "neovim installed"

# tmux: Terminal multiplexer for managing multiple terminal windows and panes
# Allows creating, managing, and navigating between multiple sessions and windows
sudo apt-get install -y tmux
print_success "tmux installed"

# github-cli: Official GitHub command-line tool
sudo apt-get install -y gh
print_success "github-cli installed"

################################################################################
# Archive and Compression Tools
################################################################################

print_header "Installing Archive and Compression Utilities"

# zip: Compression utility for creating .zip files
sudo apt-get install -y zip
print_success "zip installed"

# p7zip: 7-Zip compression utility (package name is p7zip, not 7zip)
sudo apt-get install -y p7zip-full
print_success "7zip (p7zip) installed"

################################################################################
# Enhanced Command-Line Tools
################################################################################

print_header "Installing Enhanced Command-Line Tools"

# lazygit: Terminal UI for git with an intuitive interface for managing repositories
# Provides an easy way to stage, commit, and manage branches without memorizing git commands
sudo apt-get install -y lazygit
print_success "lazygit installed"

# ripgrep (rg): Fast alternative to grep, respects .gitignore by default
sudo apt-get install -y ripgrep
print_success "ripgrep (rg) installed"

# fd: User-friendly alternative to find command with sensible defaults
sudo apt-get install -y fd-find
# Create symlink so 'fd' command works (package installs as 'fdfind')
sudo ln -sf $(which fdfind) /usr/local/bin/fd 2>/dev/null || true
print_success "fd installed"

# exa: Modern replacement for ls with better colors and git integration
sudo apt-get install -y eza
print_success "eza installed"

# bat: Better cat command with syntax highlighting and git integration
sudo apt-get install -y bat
print_success "bat installed"

# jq: JSON processor for parsing and manipulating JSON on the command line
sudo apt-get install -y jq
print_success "jq installed"

# fzf: Fuzzy finder for the terminal, useful for searching history and files
# Integrates well with zsh for enhanced command-line experience
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf 2>/dev/null || true
~/.fzf/install --all --no-bash --no-fish > /dev/null 2>&1 || true
print_success "fzf installed"

# zoxide: Smart directory navigation with 'z' command, remembers frequently visited directories
apt-get install -y zoxide
print_success "zoxide installed"

# Add zoxide initialization to shell configs
add_to_shell_configs 'eval "$(zoxide init zsh)"' "zoxide initialization"

# Configure exa aliases to replace ls commands
# This replaces the standard ls behavior with exa throughout the shell
add_to_shell_configs 'alias ls="exa --group-directories-first"' "exa ls alias"
add_to_shell_configs 'alias ll="exa -lh --group-directories-first"' "exa ll alias"
add_to_shell_configs 'alias la="exa -la --group-directories-first"' "exa la alias"
add_to_shell_configs 'alias laa="exa -lah --group-directories-first"' "exa laa alias"
add_to_shell_configs 'alias tree="exa --tree --group-directories-first"' "exa tree alias"

print_success "exa aliases configured in zshrc"

################################################################################
# Directory Environment Management (direnv)
################################################################################

# print_header "Installing Directory Environment Management (direnv)"

# # direnv: Environment switcher for the shell, allows per-directory environment variables
# # Automatically loads and unloads environment variables based on .envrc files
# sudo apt-get install -y direnv
# print_success "direnv installed"

# # Add direnv initialization to zshrc
# add_to_zshrc 'eval "$(direnv hook zsh)"' "direnv initialization"

# print_success "direnv configured in zshrc"

################################################################################
# Multi-Language Version Manager (asdf)
################################################################################

print_header "Installing ASDF Version Manager"

# asdf: Extendable version manager that can manage multiple languages and tools
# Supports plugins for different languages, providing a unified interface for version management
if [ ! -d "$ACTUAL_HOME/.asdf" ]; then
    print_info "Installing asdf..."
    git clone https://github.com/asdf-vm/asdf.git "$ACTUAL_HOME/.asdf" --branch v0.13.1 2>/dev/null || true
    chown -R "$ACTUAL_USER:$ACTUAL_USER" "$ACTUAL_HOME/.asdf"
    print_success "asdf installed"
else
    print_info "asdf already installed"
fi

# Add asdf initialization to shell configs
add_to_shell_configs 'export ASDF_CONFIG_FILE="$ACTUAL_HOME/.asdfrc"' "asdf configuration"
add_to_shell_configs '. "$ACTUAL_HOME/.asdf/asdf.sh"' "asdf initialization"
add_to_shell_configs 'fpath=(${ASDF_DIR}/completions $fpath)' "asdf completions"

print_success "asdf configured in zshrc"

print_info "Note: asdf provides unified version management for Python, Node.js, and other languages"
print_info "To use asdf instead of/alongside pyenv and nvm, install plugins with: asdf plugin add <language>"

################################################################################
# GitHub CLI Extensions
################################################################################

print_header "Installing GitHub CLI Extensions"

# gh-copilot: GitHub Copilot integration for GitHub CLI
# Allows asking AI questions directly from the command line
print_info "Installing gh-copilot extension..."
gh extension install github/gh-copilot 2>/dev/null || true
print_success "gh-copilot extension installed"

################################################################################
# Prompt Alternative: Starship
################################################################################

print_header "Installing Starship (Prompt Alternative)"

# starship: A minimal and fast prompt written in Rust
# This is an alternative to oh-my-posh with better performance
# Both can be used, but starship is recommended for speed
# To use starship instead of oh-my-posh, uncomment the lines below after installation

if ! command -v starship &> /dev/null; then
    print_info "Installing starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y > /dev/null 2>&1
    print_success "starship installed"
else
    print_info "starship already installed"
fi

print_info "Note: Starship is installed but oh-my-posh is currently active"
print_info "To switch to starship, uncomment the line below in ~/.zshrc:"
print_info "# eval \"\$(starship init zsh)\""
print_info "And comment out the oh-my-posh initialization line"

################################################################################
# Python Version Management (pyenv)
################################################################################

print_header "Setting Up Python Version Management (pyenv)"

# Install dependencies required by pyenv for building Python from source
sudo apt-get install -y \
    libssl-dev \
    libreadline-dev \
    libsqlite3-dev \
    tk-dev \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    zlib1g-dev
print_success "pyenv dependencies installed"

# Install pyenv using the official installer script from GitHub
# This method is the recommended way and handles all setup automatically
if [ ! -d "$ACTUAL_HOME/.pyenv" ]; then
    print_info "Installing pyenv using official installer..."
    curl https://pyenv.run | bash
    chown -R "$ACTUAL_USER:$ACTUAL_USER" "$ACTUAL_HOME/.pyenv"
    print_success "pyenv installed successfully"
else
    print_info "pyenv already installed, skipping installation"
fi

# Add pyenv configuration to shell configs
# This initialization must be in the shell config so it runs when the shell starts
# The installer typically adds this, but we ensure it's present
add_to_shell_configs 'export PYENV_ROOT="$ACTUAL_HOME/.pyenv"' "pyenv root directory"
add_to_shell_configs 'export PATH="$ACTUAL_HOME/.pyenv/bin:$PATH"' "pyenv initialization"
add_to_shell_configs 'eval "$(pyenv init -)"' "pyenv init"
print_success "pyenv configured in zshrc"

################################################################################
# Node Version Manager (nvm) with Auto-switching
################################################################################

print_header "Setting Up Node Version Manager (nvm) with Auto-switching"

# Install nvm (Node Version Manager) via the official installer
if [ ! -d "$ACTUAL_HOME/.nvm" ]; then
    print_info "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    chown -R "$ACTUAL_USER:$ACTUAL_USER" "$ACTUAL_HOME/.nvm"
    print_success "nvm installed"
else
    print_info "nvm already installed"
fi

# Configure nvm in shell configs for automatic initialization
add_to_shell_configs 'export NVM_DIR="$ACTUAL_HOME/.nvm"' "nvm initialization"
add_to_shell_configs '[ -s "$ACTUAL_HOME/.nvm/nvm.sh" ] && \. "$ACTUAL_HOME/.nvm/nvm.sh"' "nvm script loading"
add_to_shell_configs '[ -s "$ACTUAL_HOME/.nvm/bash_completion" ] && \. "$ACTUAL_HOME/.nvm/bash_completion"' "nvm bash completion"

# Source nvm immediately for this session (needed to install Node.js in this script)
export NVM_DIR="$ACTUAL_HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install the latest version of Node.js
print_info "Installing latest Node.js..."
nvm install node
nvm use node
print_success "Latest Node.js installed and activated"

# Set up automatic Node version switching based on .nvmrc files
print_info "Setting up automatic Node version switching..."
if [ ! -d "$ACTUAL_HOME/.nvm/plugins" ]; then
    mkdir -p "$ACTUAL_HOME/.nvm/plugins"
    chown -R "$ACTUAL_USER:$ACTUAL_USER" "$ACTUAL_HOME/.nvm/plugins"
fi

if [ ! -f "$ACTUAL_HOME/.nvm/plugins/nvm-auto-use.sh" ]; then
    # Create a simple auto-use script that switches Node versions based on .nvmrc
    cat > "$ACTUAL_HOME/.nvm/plugins/nvm-auto-use.sh" << 'EOF'
# Auto-use Node.js version from .nvmrc file when entering a directory
find_nvm_version() {
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/.nvmrc" ]]; then
            echo "Found .nvmrc in $dir"
            nvm use
            return 0
        fi
        dir=$(dirname "$dir")
    done
    return 1
}

# Run auto-use check when directory changes
# This overrides the built-in cd command to check for .nvmrc on directory change
cd() {
    builtin cd "$@"
    find_nvm_version || true
}
EOF
    chown \"$ACTUAL_USER:$ACTUAL_USER\" \"$ACTUAL_HOME/.nvm/plugins/nvm-auto-use.sh\"
    print_success "Auto-use script created"
else
    print_info "Auto-use script already exists"
fi

# Add auto-use script to shell configs
add_to_shell_configs '[ -s \"$ACTUAL_HOME/.nvm/plugins/nvm-auto-use.sh\" ] && \\. \"$ACTUAL_HOME/.nvm/plugins/nvm-auto-use.sh\"' "nvm auto-use plugin"
print_success "Auto-use plugin configured in zshrc"

################################################################################
# Jekyll (Static Site Generator)
################################################################################

print_header "Installing Jekyll"

# Install Ruby (Jekyll is a Ruby application) and required development files
sudo apt-get install -y ruby ruby-dev
print_success "Ruby installed"

# Install bundler and Jekyll gems
# bundler: Dependency manager for Ruby projects
# jekyll: Static site generator written in Ruby
sudo gem install bundler jekyll
print_success "Jekyll installed"

################################################################################
# GitKraken Installation
################################################################################

print_header "Installing GitKraken"

# Note: GitKraken is primarily a GUI application and may require additional setup in WSL
# It's recommended to install the Windows version separately if needed for GUI functionality
# Here we attempt to install via snap (which may not work on all WSL configs)

if command -v snap &> /dev/null; then
    print_info "Installing GitKraken via snap..."
    sudo snap install gitkraken --classic
    print_success "GitKraken installed via snap"
else
    print_error "Snap not available. For GitKraken GUI, install the Windows version from: https://www.gitkraken.com/"
    print_info "Command-line git integration tools are available in this WSL instance"
fi

################################################################################
# Final Summary and Next Steps
################################################################################

print_header "Setup Complete!"

echo -e "${GREEN}All packages have been installed and configured for zsh!${NC}\n"

echo -e "${YELLOW}Summary of installed tools:${NC}"
echo "  ✓ Shell Environment: zsh, oh-my-zsh, oh-my-posh"
echo "  ✓ Fonts: 0xProto Nerd Font"
echo "  ✓ Build Tools: build-essential, curl, wget"
echo "  ✓ Process Management: htop, tmux"
echo "  ✓ Text Editors: neovim"
echo "  ✓ Compression: zip, unzip, 7zip"
echo "  ✓ Version Management: pyenv, nvm, asdf"
echo "  ✓ Node.js/JavaScript: Node.js LTS"
echo "  ✓ Python: pyenv configured"
echo "  ✓ Ruby: ruby, bundler, jekyll"
echo "  ✓ Version Control: git, github-cli, gh-copilot, lazygit"
echo "  ✓ Command-Line Tools:"
echo "     - ripgrep (rg): Fast grep alternative"
echo "     - fd: Modern find replacement"
echo "     - exa: Enhanced ls with aliases (ls, ll, la, laa, tree)"
echo "     - bat: Syntax-highlighted cat"
echo "     - jq: JSON processor"
echo "     - tldr: Simplified man pages"
echo "     - fzf: Fuzzy finder"
echo "     - zoxide: Smart directory navigation (z command)"
echo "  ✓ Environment Management: direnv"
echo "  ✓ Prompt Engines: oh-my-posh (active), starship (installed, optional)"
echo "  ⓘ GitKraken: Available (see notes below)"

echo -e "\n${YELLOW}Configuration Details:${NC}"
echo "  • All environment variables configured in ~/.zshrc"
echo "  • pyenv fully initialized for Python version management"
echo "  • nvm fully initialized for Node.js with auto-switching via .nvmrc"
echo "  • asdf ready for additional language/tool version management"
echo "  • Oh-My-Zsh ready with plugins and theme customization"
echo "  • Oh-My-Posh active with powerline theme and 0xProto Nerd Font"
echo "  • exa replaces ls completely with custom aliases"
echo "  • zoxide enables smart directory navigation with z command"
echo "  • direnv enables per-directory environment configuration"
echo "  • fzf integrated for fuzzy finding throughout shell"
echo "  • gh-copilot available for AI-assisted command-line help"

echo -e "\n${YELLOW}Quick Command Reference:${NC}"
echo "  z <directory>       - Jump to frequently used directories (zoxide)"
echo "  lazygit             - Git UI in terminal"
echo "  rg <pattern>        - Fast grep alternative"
echo "  fd <pattern>        - Find files efficiently"
echo "  ls/ll/la/tree       - exa-powered listing commands"
echo "  cat <file>          - Syntax-highlighted output (bat alias)"
echo "  fzf                 - Fuzzy finder for files/commands"
echo "  jq                  - JSON processing"
echo "  tldr <command>      - Quick command examples"
echo "  gh copilot          - AI assistance for CLI"
echo "  nvm use <version>   - Switch Node versions (auto via .nvmrc)"
echo "  pyenv install <ver> - Install Python versions"

echo -e "\n${YELLOW}Next Steps:${NC}"
echo "  1. Start a new zsh session: exec zsh"
echo "  2. Verify core installations:"
echo "     - node --version"
echo "     - python3 --version"
echo "     - nvim --version"
echo "     - ruby --version"
echo "  3. Configure terminal to use 0xProto Nerd Font for proper icons"
echo "  4. Test version managers:"
echo "     - pyenv versions && pyenv install 3.12"
echo "     - nvm list"
echo "     - asdf plugin list"
echo "  5. Test enhanced commands:"
echo "     - z (navigate with zoxide)"
echo "     - lazygit (for git repositories)"
echo "     - fzf (Ctrl+R in history, Ctrl+T for files)"
echo "  6. Create .envrc for direnv in projects: echo 'export MY_VAR=value' > .envrc && direnv allow"
echo "  7. Create .nvmrc in Node projects: echo 'lts/*' > .nvmrc"
echo "  8. For GitKraken GUI: Install Windows version from https://www.gitkraken.com/"

echo -e "\n${YELLOW}Customization Tips:${NC}"
echo "  • Change oh-my-posh theme: edit init line in ~/.zshrc"
echo "  • Switch to Starship: uncomment starship init in ~/.zshrc, comment oh-my-posh"
echo "  • Add oh-my-zsh plugins: edit 'plugins=()' in ~/.zshrc"
echo "  • Useful plugins: git, node, npm, nvm, python, pyenv, zoxide, fzf"
echo "  • Configure direnv: create/edit ~/.direnvrc for shared functions"
echo "  • Add asdf plugins: asdf plugin add <language>"

echo -e "\n${YELLOW}Useful zsh and oh-my-zsh features:${NC}"
echo "  • omz command help"
echo "  • omz theme list - Browse available themes"
echo "  • omz plugin list - Browse available plugins"
echo "  • omz reload - Reload your zsh configuration"
echo "  • omz update - Update oh-my-zsh"

echo -e "\n${GREEN}Happy coding with zsh, oh-my-posh, and enhanced CLI tools!${NC}\n"
