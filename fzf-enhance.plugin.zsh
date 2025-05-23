# === Plugin: fzf-enhance ===
# Smart alias registration with conflict avoidance

# Check if a command exists
check_command() {
  command -v "$1" &>/dev/null
}

# Check dependencies and print warning if missing
check_dependencies() {
  local missing_deps=()
  
  if ! check_command fzf; then
    missing_deps+=("fzf")
  fi
  
  if ! check_command git; then
    missing_deps+=("git")
  fi
  
  if ! check_command fd; then
    missing_deps+=("fd")
  fi
  
  if ! check_command zoxide; then
    missing_deps+=("zoxide")
  fi
  
  if [[ ${#missing_deps[@]} -gt 0 ]]; then
    echo "⚠️ fzf-enhance: Missing dependencies: ${missing_deps[*]}"
    echo "  Some features will be disabled."
  fi
}

register_fzf_alias() {
  local base="$1"
  local raw_command="$2"
  local name

  if [[ "$FZF_ENHANCE_OVERRIDE" == "1" ]]; then
    name="$base"
  else
    name="f$base"
  fi

  # 如果 alias 或系统命令已存在，跳过
  if alias "$name" &>/dev/null || command -v "$name" &>/dev/null; then
    echo "⚠️ Skipping alias '$name': already defined"
    return
  fi

  # 将命令中的双引号变为 '\''，用于单引号包裹的 eval
  local escaped_command=${raw_command//\"/\'\"\'\"\'}

  # 构造完整 eval 命令：alias name='escaped_command'
  eval "alias ${name}='$escaped_command'"
}

# Check dependencies first
check_dependencies

# Exit early if fzf is not available
if ! check_command fzf; then
  echo "❌ fzf-enhance: fzf not found. Plugin disabled."
  return
fi

# === 🟦 Git commands ===
if check_command git; then
  register_fzf_alias gco  'git branch --format="%(refname:short)" | fzf --prompt="Checkout branch > " --bind "enter:execute(git checkout {+})+abort"'
  register_fzf_alias gbb  'git branch --all --format="%(refname:short)" | fzf --prompt="Checkout any branch > " --bind "enter:execute(git checkout {+})+abort"'
  register_fzf_alias gcb  'git branch -r | sed "s/origin\///" | sort -u | fzf --prompt="Checkout remote branch > " --bind "enter:execute(git checkout -t origin/{+})+abort"'
  register_fzf_alias grm  'git branch --format="%(refname:short)" | fzf --prompt="Delete branch > " --bind "enter:execute(git branch -d {+})+abort"'
  register_fzf_alias gtag 'git tag | fzf --prompt="Checkout tag > " --bind "enter:execute(git checkout {+})+abort"'
  register_fzf_alias gcm  'git log --oneline --color=always | fzf --ansi --no-sort --reverse --preview="git show --color=always {1}" --bind "enter:execute-silent(echo {1} | cut -d\" \" -f1 | pbcopy)+abort"'
  register_fzf_alias gcf  'git ls-files | fzf --preview "bat --style=numbers --color=always {}" --bind "enter:execute(nvim {})+abort"'
  register_fzf_alias gst  'git status -s | awk "{print \$2}" | fzf --preview "git diff --color=always {}" --bind "enter:execute(nvim {})+abort"'
  register_fzf_alias groot 'cd $(git rev-parse --show-toplevel)'
else
  echo "⚠️ fzf-enhance: git not found. Git-related aliases disabled."
fi

# === 🟩 File navigation ===
register_fzf_alias ff    'fzf --preview "bat --style=numbers --color=always {}" --bind "enter:execute(nvim {})+abort"'

if check_command fd; then
  register_fzf_alias fcd   'fd --type d | fzf --prompt="CD into dir > " --bind "enter:execute(cd {})+abort"'
else
  echo "⚠️ fzf-enhance: fd not found. Directory navigation (fcd) disabled."
fi

# === 🟥 System tools ===
register_fzf_alias fkill 'ps -ef | sed 1d | fzf --header="Select process to kill" --bind "enter:execute(kill -9 {1})+abort" --preview "echo PID: {1}"'

# === 🟨 General utilities ===
register_fzf_alias fh   'history | fzf --tac --preview "echo {}" --bind "enter:execute-silent(echo {} | cut -c 8- | pbcopy)+abort"'

if check_command zoxide; then
  register_fzf_alias zjump 'zoxide query -l | fzf --prompt="Jump to > " --bind "enter:execute(cd {+})+abort"'
else
  echo "⚠️ fzf-enhance: zoxide not found. Directory jumping (zjump) disabled."
fi

if check_command dict; then
  register_fzf_alias dict 'pbpaste | fzf --preview "dict {}" --bind "enter:abort"'
else
  echo "⚠️ fzf-enhance: dict not found. Dictionary lookup disabled."
fi

