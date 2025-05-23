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
  local force_prefix="$3"  # New parameter: force prefix usage
  local name

  if [[ "$force_prefix" == "true" ]]; then
    # Force prefix usage, ignore FZF_ENHANCE_OVERRIDE
    name="f$base"
  elif [[ "$FZF_ENHANCE_OVERRIDE" == "1" ]]; then
    name="$base"
  else
    name="f$base"
  fi

  # Skip if alias or system command already exists
  if alias "$name" &>/dev/null || command -v "$name" &>/dev/null; then
    echo "⚠️ Skipping alias '$name': already defined"
    return
  fi

  # Use printf to safely escape commands, avoiding complex quote handling
  eval "alias $name='$raw_command'"
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
  
  register_fzf_alias gshow 'git log --oneline --color=always | fzf --ansi --no-sort --reverse --preview="git show --color=always {1}" --bind "enter:execute(git show {1})+abort"'
  register_fzf_alias greset 'git log --oneline --color=always | fzf --ansi --no-sort --reverse --preview="git show --color=always {1}" --prompt="Reset to commit > " --bind "enter:execute(git reset --hard {1})+abort"'
  register_fzf_alias gcherry 'git log --oneline --color=always --all | fzf --ansi --no-sort --reverse --preview="git show --color=always {1}" --prompt="Cherry-pick commit > " --bind "enter:execute(git cherry-pick {1})+abort"'
  register_fzf_alias gstash 'git stash list | fzf --prompt="Manage stash > " --preview="git stash show -p {1}" --bind "enter:execute(git stash apply {1})+abort,ctrl-d:execute(git stash drop {1})+abort"'
  
  register_fzf_alias gremote 'git remote -v | fzf --prompt="Manage remote > " --preview="git remote show {1}" --bind "enter:abort"'
  register_fzf_alias gfetch 'git branch -r | fzf --prompt="Fetch branch > " --bind "enter:execute(git fetch origin {+})+abort"'
  register_fzf_alias gpull 'git branch --format="%(refname:short)" | fzf --prompt="Pull branch > " --bind "enter:execute(git pull origin {+})+abort"'
  
  register_fzf_alias glog 'git ls-files | fzf --preview "git log --oneline --color=always -- {}" --prompt="File git log > " --bind "enter:execute(git log --color=always -- {})+abort"'
  register_fzf_alias gblame 'git ls-files | fzf --preview "git blame --color-lines {}" --prompt="Git blame file > " --bind "enter:execute(git blame {})+abort"'
else
  echo "⚠️ fzf-enhance: git not found. Git-related aliases disabled."
fi

# === 🟩 File navigation ===
register_fzf_alias f    'fzf --preview "bat --style=numbers --color=always {}" --bind "enter:execute(nvim {})+abort"'

if check_command fd; then
  register_fzf_alias cd   'fd --type d | fzf --prompt="CD into dir > " --bind "enter:execute(cd {})+abort"' true
  
  register_fzf_alias code 'fd --type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" -o -name "*.go" -o -name "*.rs" -o -name "*.java" -o -name "*.c" -o -name "*.cpp" -o -name "*.h" \) | fzf --preview "bat --style=numbers --color=always {}" --prompt="Search in code > " --bind "enter:execute(nvim {})+abort"'
  register_fzf_alias recent 'fd --type f --print0 | xargs -0 ls -lt | head -50 | awk "{print \$NF}" | fzf --preview "bat --style=numbers --color=always {}" --prompt="Recent files > " --bind "enter:execute(nvim {})+abort"'
  register_fzf_alias size 'fd --type f | xargs ls -lah | sort -k5 -h | fzf --preview "bat --style=numbers --color=always {9}" --prompt="Files by size > " --bind "enter:execute(nvim {9})+abort"'
  register_fzf_alias ext 'fd --type f | grep -E "\.[^.]+$" | sed "s/.*\.//" | sort | uniq -c | sort -nr | fzf --prompt="Select extension > " | awk "{print \$2}" | xargs -I {} fd --type f --extension {}'
  
  register_fzf_alias mkdir 'echo -n "New directory name: " && read dirname && mkdir -p "$dirname" && cd "$dirname"' true
  
  # File copy function
  register_fzf_alias cp 'file=$(fd --type f | fzf --prompt="Copy file > ") && [[ -n "$file" ]] && dir=$(fd --type d | fzf --prompt="To directory > ") && [[ -n "$dir" ]] && cp "$file" "$dir" && echo "Copied $file to $dir"' true
  
  # File move function  
  register_fzf_alias mv 'file=$(fd --type f | fzf --prompt="Move file > ") && [[ -n "$file" ]] && dir=$(fd --type d | fzf --prompt="To directory > ") && [[ -n "$dir" ]] && mv "$file" "$dir" && echo "Moved $file to $dir"' true
else
  echo "⚠️ fzf-enhance: fd not found. Enhanced file navigation disabled."
fi

# === 🟥 System tools ===
register_fzf_alias kill 'ps -ef | sed 1d | fzf --header="Select process to kill" --bind "enter:execute(kill -9 {1})+abort" --preview "echo PID: {1}"' true

register_fzf_alias port 'lsof -i -P -n | grep LISTEN | fzf --prompt="Kill process on port > " --bind "enter:execute(kill -9 {2})+abort"'
register_fzf_alias top 'ps aux --sort=-%cpu | head -20 | fzf --header="Top processes by CPU" --bind "enter:execute(kill -9 {2})+abort"' true
register_fzf_alias ping 'echo -e "google.com\n8.8.8.8\n1.1.1.1\nlocalhost" | fzf --prompt="Ping host > " --bind "enter:execute(ping {})+abort"' true

if [[ -f ~/.ssh/config ]]; then
  register_fzf_alias ss 'grep "^Host " ~/.ssh/config | awk "{print \$2}" | fzf --prompt="SSH to > " --bind "enter:execute(ssh {})+abort"'
fi

if [[ -f /etc/hosts ]]; then
  register_fzf_alias host 'cat /etc/hosts | grep -v "^#" | fzf --prompt="Edit hosts > " --bind "enter:execute(sudo nvim /etc/hosts)+abort"' true
fi

if check_command systemctl; then
  register_fzf_alias service 'systemctl list-units --type=service | fzf --prompt="Manage service > " --bind "enter:execute(systemctl status {1})+abort,ctrl-r:execute(sudo systemctl restart {1})+abort,ctrl-s:execute(sudo systemctl stop {1})+abort"' true
fi

# === 🟨 General utilities ===
register_fzf_alias h   'history | fzf --tac --preview "echo {}" --bind "enter:execute-silent(echo {} | cut -c 8- | pbcopy)+abort"'

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

register_fzf_alias env 'env | sort | fzf --prompt="Environment variables > " --preview "echo {}" --bind "enter:execute-silent(echo {} | pbcopy)+abort"' true
register_fzf_alias path 'echo $PATH | tr ":" "\n" | fzf --prompt="PATH entries > " --bind "enter:execute(ls -la {})+abort"'

register_fzf_alias config 'echo -e "~/.zshrc\n~/.bashrc\n~/.vimrc\n~/.gitconfig\n~/.ssh/config" | fzf --prompt="Edit config > " --bind "enter:execute(nvim {})+abort"'
register_fzf_alias dotfile 'fd --hidden --type f --max-depth 1 "^\." ~ | fzf --prompt="Edit dotfile > " --bind "enter:execute(nvim {})+abort"'

if check_command brew; then
  register_fzf_alias pkg 'brew list | fzf --prompt="Manage package > " --preview "brew info {}" --bind "enter:execute(brew info {})+abort,ctrl-u:execute(brew uninstall {})+abort"'
elif check_command apt; then
  register_fzf_alias pkg 'dpkg -l | awk "{print \$2}" | fzf --prompt="Manage package > " --preview "apt show {}" --bind "enter:execute(apt show {})+abort"'
fi

if check_command docker; then
  register_fzf_alias docker 'docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" | fzf --header-lines=1 --prompt="Docker container > " --bind "enter:execute(docker exec -it {1} /bin/bash)+abort,ctrl-s:execute(docker start {1})+abort,ctrl-p:execute(docker stop {1})+abort,ctrl-r:execute(docker restart {1})+abort"' true
fi

if check_command npm; then
  register_fzf_alias node 'npm list -g --depth=0 2>/dev/null | sed "1d" | fzf --prompt="Node packages > " --bind "enter:execute(npm info {})+abort"' true
fi

# === 🟪 Development tools ===
register_fzf_alias lint 'find . -name "*.py" -o -name "*.js" -o -name "*.ts" | fzf --prompt="Lint file > " --bind "enter:execute(echo \"Linting {}...\" && if [[ {} == *.py ]]; then flake8 {}; elif [[ {} == *.js || {} == *.ts ]]; then eslint {}; fi)+abort"'

if [[ -d "./tests" ]] || [[ -d "./test" ]]; then
  register_fzf_alias test 'find . -path "*/test*" -name "*.py" -o -name "*.js" -o -name "*.ts" | fzf --prompt="Run test > " --bind "enter:execute(echo \"Running test {}...\" && if [[ {} == *.py ]]; then python {}; else npm test {}; fi)+abort"' true
fi

if [[ -f "package.json" ]]; then
  register_fzf_alias build 'echo -e "npm run build\nnpm run dev\nnpm run start\nnpm run test" | fzf --prompt="Build command > " --bind "enter:execute({})+abort"'
elif [[ -f "Makefile" ]]; then
  register_fzf_alias build 'grep "^[a-zA-Z0-9_-]*:" Makefile | sed "s/:.*//" | fzf --prompt="Make target > " --bind "enter:execute(make {})+abort"'
fi

# === 🟧 Media and documents ===
register_fzf_alias md 'fd --extension md | fzf --preview "bat --style=numbers --color=always {}" --prompt="Markdown files > " --bind "enter:execute(nvim {})+abort"'

if check_command find; then
  register_fzf_alias pdf 'find . -name "*.pdf" | fzf --prompt="PDF files > " --bind "enter:execute(open {})+abort"'
  register_fzf_alias img 'find . \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" -o -name "*.bmp" \) | fzf --prompt="Image files > " --bind "enter:execute(open {})+abort"'
  register_fzf_alias video 'find . \( -name "*.mp4" -o -name "*.avi" -o -name "*.mkv" -o -name "*.mov" -o -name "*.wmv" \) | fzf --prompt="Video files > " --bind "enter:execute(open {})+abort"'
fi

register_fzf_alias log 'find /var/log -name "*.log" 2>/dev/null | fzf --prompt="Log files > " --preview "tail -20 {}" --bind "enter:execute(tail -f {})+abort"'

echo "✅ fzf-enhance: All enhanced features loaded successfully!"

