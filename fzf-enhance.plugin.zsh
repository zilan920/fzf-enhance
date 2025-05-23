# === Plugin: fzf-enhance ===
# Smart alias registration (supports optional override)

register_fzf_alias() {
  local name="$1"
  local command="$2"

  if [[ "$FZF_ENHANCE_OVERRIDE" == "1" || -z "$(alias "$name" 2>/dev/null)" ]]; then
    alias "$name"="$command"
  else
    alias "${name}_"="$command"
  fi
}

# === 🟦 Git aliases ===
register_fzf_alias gco 'git branch | grep -v "HEAD" | sed "s/.* //" | fzf --prompt="Checkout branch > " --bind "enter:execute(git checkout {+})+abort"'
register_fzf_alias gbb 'git branch --all | grep -v "HEAD" | sed "s/.* //" | sort -u | fzf --prompt="Select branch > " --bind "enter:execute(git checkout {+})+abort"'
register_fzf_alias gcb 'git branch -r | grep -v "HEAD" | sed "s/origin\///" | sort -u | fzf --prompt="Checkout remote > " --bind "enter:execute(git checkout -t origin/{+})+abort"'
register_fzf_alias grm 'git branch | grep -v "HEAD" | sed "s/.* //" | fzf --prompt="Delete branch > " --bind "enter:execute(git branch -d {+})+abort"'
register_fzf_alias gtag 'git tag | fzf --prompt="Checkout tag > " --bind "enter:execute(git checkout {+})+abort"'
register_fzf_alias gcm 'git log --oneline --color=always | fzf --ansi --no-sort --reverse --preview="git show --color=always {1}" --bind "enter:execute-silent(echo {1} | cut -d\" \" -f1 | pbcopy)+abort"'
register_fzf_alias gcf 'git ls-files | fzf --preview "bat --style=numbers --color=always {}" --bind "enter:execute(nvim {})+abort"'
register_fzf_alias gst 'git status -s | awk "{print \$2}" | fzf --preview "git diff --color=always {}" --bind "enter:execute(nvim {})+abort"'

# === 🟩 File navigation ===
register_fzf_alias ff 'fzf --preview "bat --style=numbers --color=always {}" --bind "enter:execute(nvim {})+abort"'
register_fzf_alias fcd 'fd --type d | fzf --prompt="CD into dir > " --bind "enter:execute(cd {})+abort"'
register_fzf_alias groot 'cd $(git rev-parse --show-toplevel)'

# === 🟥 System tools ===
register_fzf_alias fkill 'ps -ef | sed 1d | fzf --header="Select process to kill" --bind "enter:execute(kill -9 {1})+abort" --preview "echo PID: {1}"'

# === 🟨 General utilities ===
register_fzf_alias fh 'history | fzf --tac --preview "echo {}" --bind "enter:execute-silent(echo {} | cut -c 8- | pbcopy)+abort"'
register_fzf_alias zf 'zoxide query -l | fzf --prompt="Jump to > " --bind "enter:execute(cd {+})+abort"'
register_fzf_alias dict 'pbpaste | fzf --preview "dict {}" --bind "enter:abort"'

