# === Plugin: fzf-enhance ===
# Smart alias registration with conflict avoidance

register_fzf_alias() {
  local base="$1"
  local raw_command="$2"
  local name

  if [[ "$FZF_ENHANCE_OVERRIDE" == "1" ]]; then
    name="$base"
  else
    name="f$base"
  fi

  # skip if alias or system command already exists
  if alias "$name" &>/dev/null || command -v "$name" &>/dev/null; then
    echo "⚠️ Skipping alias '$name': already defined"
    return
  fi

  # Escape all { } inside command
  local command="${raw_command//\{/\{\\{}"
  command="${command//\}/\\}\}"

  eval "alias ${name}=\"${command}\""
}


# === 🟦 Git commands ===

register_fzf_alias gco  'git branch --format="%(refname:short)" | fzf --prompt="Checkout branch > " --bind "enter:execute(git checkout {+})+abort"'
register_fzf_alias gbb  'git branch --all --format="%(refname:short)" | fzf --prompt="Checkout any branch > " --bind "enter:execute(git checkout {+})+abort"'
register_fzf_alias gcb  'git branch -r | sed "s/origin\///" | sort -u | fzf --prompt="Checkout remote branch > " --bind "enter:execute(git checkout -t origin/{+})+abort"'
register_fzf_alias grm  'git branch --format="%(refname:short)" | fzf --prompt="Delete branch > " --bind "enter:execute(git branch -d {+})+abort"'
register_fzf_alias gtag 'git tag | fzf --prompt="Checkout tag > " --bind "enter:execute(git checkout {+})+abort"'
register_fzf_alias gcm  'git log --oneline --color=always | fzf --ansi --no-sort --reverse --preview="git show --color=always {1}" --bind "enter:execute-silent(echo {1} | cut -d\" \" -f1 | pbcopy)+abort"'
register_fzf_alias gcf  'git ls-files | fzf --preview "bat --style=numbers --color=always {}" --bind "enter:execute(nvim {})+abort"'
register_fzf_alias gst  'git status -s | awk "{print \$2}" | fzf --preview "git diff --color=always {}" --bind "enter:execute(nvim {})+abort"'

# === 🟩 File navigation ===

register_fzf_alias ff    'fzf --preview "bat --style=numbers --color=always {}" --bind "enter:execute(nvim {})+abort"'
register_fzf_alias fcd   'fd --type d | fzf --prompt="CD into dir > " --bind "enter:execute(cd {})+abort"'
register_fzf_alias groot 'cd $(git rev-parse --show-toplevel)'

# === 🟥 System tools ===

register_fzf_alias fkill 'ps -ef | sed 1d | fzf --header="Select process to kill" --bind "enter:execute(kill -9 {1})+abort" --preview "echo PID: {1}"'

# === 🟨 General utilities ===

register_fzf_alias fh   'history | fzf --tac --preview "echo {}" --bind "enter:execute-silent(echo {} | cut -c 8- | pbcopy)+abort"'
register_fzf_alias zjump 'zoxide query -l | fzf --prompt="Jump to > " --bind "enter:execute(cd {+})+abort"'
register_fzf_alias dict 'pbpaste | fzf --preview "dict {}" --bind "enter:abort"'

