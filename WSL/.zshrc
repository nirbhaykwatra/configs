# .zshrc - Zsh configuration file
# Generated after running the Ubuntu 25.10 WSL Development Environment Setup Script
# This file contains all configurations for zsh, oh-my-zsh, and installed tools

# oh-my-zsh initialization
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"  # Default theme (can be customized)

# oh-my-zsh plugins
plugins=(git)  # Add more plugins as needed: git node npm nvm python pyenv zoxide fzf

# Load oh-my-zsh
source $ZSH/oh-my-zsh.sh

################################################################################
# oh-my-posh initialization
################################################################################

# oh-my-posh initialization
eval "$(oh-my-posh init zsh --config ~/.configs/nirbhaykwatra.omp.json)"

################################################################################
# zoxide initialization
################################################################################

# zoxide initialization
eval "$(zoxide init zsh)"

################################################################################
# exa ls alias
################################################################################

# exa ls alias
alias ls="exa --group-directories-first"

################################################################################
# exa ll alias
################################################################################

# exa ll alias
alias ll="exa -lh --group-directories-first"

################################################################################
# exa la alias
################################################################################

# exa la alias
alias la="exa -la --group-directories-first"

################################################################################
# exa laa alias
################################################################################

# exa laa alias
alias laa="exa -lah --group-directories-first"

################################################################################
# exa tree alias
################################################################################

# exa tree alias
alias tree="exa --tree --group-directories-first"

################################################################################
# asdf configuration
################################################################################

# asdf configuration
export ASDF_CONFIG_FILE="$HOME/.asdfrc"

################################################################################
# asdf initialization
################################################################################

# asdf initialization
. "$HOME/.asdf/asdf.sh"

################################################################################
# asdf completions
################################################################################

# asdf completions
fpath=(${ASDF_DIR}/completions $fpath)

################################################################################
# nvm initialization
################################################################################

# nvm initialization
export NVM_DIR="$HOME/.nvm"

################################################################################
# nvm script loading
################################################################################

# nvm script loading
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

################################################################################
# nvm bash completion
################################################################################

# nvm bash completion
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

################################################################################
# nvm auto-use plugin
################################################################################

# nvm auto-use plugin
[ -s "$HOME/.nvm/plugins/nvm-auto-use.sh" ] && \. "$HOME/.nvm/plugins/nvm-auto-use.sh"

################################################################################
# pyenv root directory
################################################################################

# pyenv root directory
export PYENV_ROOT="$HOME/.pyenv"

################################################################################
# pyenv initialization
################################################################################

# pyenv initialization
export PATH="$PYENV_ROOT/bin:$PATH"

################################################################################
# pyenv init
################################################################################

# pyenv init
eval "$(pyenv init -)"

################################################################################
# Additional Configuration (Optional)
################################################################################

# You can add additional configurations below this line:
# - Custom aliases
# - Environment variables
# - Shell options
# - Custom functions

# Example: Add custom aliases
# alias gs="git status"
# alias ga="git add"
# alias gc="git commit"

# Example: Add custom environment variables
# export EDITOR="nvim"
# export LANG="en_US.UTF-8"

# Example: Enable command history search with arrow keys
# bindkey '^[[A' history-search-backward
# bindkey '^[[B' history-search-forward
