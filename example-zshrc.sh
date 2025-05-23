# Example ~/.zshrc configuration for fzf-enhance

# Optional: Override existing commands (uncomment to enable)
# export FZF_ENHANCE_OVERRIDE=1

# Load Oh My Zsh with fzf-enhance plugin
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"  # or your preferred theme

plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
  fzf-enhance  # Add fzf-enhance to your plugins
)

source $ZSH/oh-my-zsh.sh

# Optional: Custom fzf configuration
export FZF_DEFAULT_OPTS="
  --height 50%
  --layout=reverse
  --border
  --preview-window=right:60%
  --bind 'ctrl-y:execute-silent(echo -n {} | pbcopy)'
"

# Optional: Custom key bindings for enhanced workflow
bindkey '^G' fzf-git-widget      # Ctrl+G for git operations
bindkey '^F' fzf-file-widget     # Ctrl+F for file operations
bindkey '^K' fzf-kill-widget     # Ctrl+K for process killing

# Example aliases that work well with fzf-enhance
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'

# Git aliases that complement fzf-enhance
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'

echo "✨ fzf-enhance loaded! Try these commands:"
echo "  🔹 fgco  - Interactive git checkout"
echo "  🔹 fgst  - Interactive git status"
echo "  🔹 fff   - Find and edit files"
echo "  🔹 fkill - Interactive process killer"
echo "  🔹 fdocker - Docker container management"
echo "  🔹 fconfig - Quick config file editing" 