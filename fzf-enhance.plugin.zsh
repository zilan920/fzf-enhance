# === Plugin: fzf-enhance ===
# Smart alias registration with conflict avoidance

# Store plugin directory at load time for reliable updates
FZF_ENHANCE_PLUGIN_DIR="$(dirname "${(%):-%x}")"

# Array to store all registered commands for listing
declare -a FZF_ENHANCE_COMMANDS

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
  local description="$4"   # New parameter: command description
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
  
  # Add to registered commands list with description
  local desc="${description:-No description available}"
  FZF_ENHANCE_COMMANDS+=("$name|$desc")
}

# Function to list all registered commands
list_fzf_commands() {
  # Format commands for fzf display
  local formatted_commands=()
  for cmd_info in "${FZF_ENHANCE_COMMANDS[@]}"; do
    local cmd_name="${cmd_info%%|*}"
    local cmd_desc="${cmd_info##*|}"
    formatted_commands+=("$(printf "%-12s %s" "$cmd_name" "$cmd_desc")")
  done
  
  # Use fzf to display commands interactively
  printf '%s\n' "${formatted_commands[@]}" | \
    fzf --prompt="fzf-enhance commands > " \
        --header="Press Enter to copy command to clipboard, Ctrl+C to exit" \
        --preview="echo 'Command: {}' | head -1 | awk '{print \$2}'" \
        --bind "enter:execute-silent(echo {} | awk '{print \$1}' | pbcopy)+abort"
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
  register_fzf_alias gco  'git branch --format="%(refname:short)" | fzf --prompt="Checkout branch > " --bind "enter:execute(git checkout {+})+abort"' false "Interactive branch checkout"
  register_fzf_alias gbb  'git branch --all --format="%(refname:short)" | fzf --prompt="Checkout any branch > " --bind "enter:execute(git checkout {+})+abort"' false "Browse and switch to all branches (including remote)"
  register_fzf_alias gcb  'git branch -r | sed "s/origin\///" | sort -u | fzf --prompt="Checkout remote branch > " --bind "enter:execute(git checkout -t origin/{+})+abort"' false "Checkout remote branch (creates tracking branch)"
  register_fzf_alias grm  'git branch --format="%(refname:short)" | fzf --prompt="Delete branch > " --bind "enter:execute(git branch -d {+})+abort"' false "Interactive local branch deletion"
  register_fzf_alias gtag 'git tag | fzf --prompt="Checkout tag > " --bind "enter:execute(git checkout {+})+abort"' false "Checkout tags"
  register_fzf_alias gcm  'git log --oneline --color=always | fzf --ansi --no-sort --reverse --preview="git show --color=always {1}" --bind "enter:execute-silent(echo {1} | cut -d\" \" -f1 | pbcopy)+abort"' false "Copy recent commit hash"
  register_fzf_alias gcf  'git ls-files | fzf --preview "bat --style=numbers --color=always {}" --bind "enter:execute(nvim {})+abort"' false "Browse and edit git repository files"
  register_fzf_alias gst  'git status -s | awk "{print \$2}" | fzf --preview "git diff --color=always {}" --bind "enter:execute(nvim {})+abort"' false "Show and edit modified files (git status)"
  register_fzf_alias groot 'cd $(git rev-parse --show-toplevel)' false "Jump to git root directory"
  
  register_fzf_alias gshow 'git log --oneline --color=always | fzf --ansi --no-sort --reverse --preview="git show --color=always {1}" --bind "enter:execute(git show {1})+abort"' false "Interactive commit details and diff viewer"
  register_fzf_alias greset 'git log --oneline --color=always | fzf --ansi --no-sort --reverse --preview="git show --color=always {1}" --prompt="Reset to commit > " --bind "enter:execute(git reset --hard {1})+abort"' false "Interactive reset to specific commit"
  register_fzf_alias gcherry 'git log --oneline --color=always --all | fzf --ansi --no-sort --reverse --preview="git show --color=always {1}" --prompt="Cherry-pick commit > " --bind "enter:execute(git cherry-pick {1})+abort"' false "Interactive cherry-pick commits"
  register_fzf_alias gstash 'git stash list | fzf --prompt="Manage stash > " --preview="git stash show -p {1}" --bind "enter:execute(git stash apply {1})+abort,ctrl-d:execute(git stash drop {1})+abort"' false "Interactive stash management (Ctrl+D to delete)"
  
  register_fzf_alias gremote 'git remote -v | fzf --prompt="Manage remote > " --preview="git remote show {1}" --bind "enter:abort"' false "Interactive remote repository information"
  register_fzf_alias gfetch 'git branch -r | fzf --prompt="Fetch branch > " --bind "enter:execute(git fetch origin {+})+abort"' false "Selective fetch from remote branches"
  register_fzf_alias gpull 'git branch --format="%(refname:short)" | fzf --prompt="Pull branch > " --bind "enter:execute(git pull origin {+})+abort"' false "Select branch for pull operations"
  
  register_fzf_alias glog 'git ls-files | fzf --preview "git log --oneline --color=always -- {}" --prompt="File git log > " --bind "enter:execute(git log --color=always -- {})+abort"' false "Interactive file git history viewer"
  register_fzf_alias gblame 'git ls-files | fzf --preview "git blame --color-lines {}" --prompt="Git blame file > " --bind "enter:execute(git blame {})+abort"' false "Select file for blame information"
else
  echo "⚠️ fzf-enhance: git not found. Git-related aliases disabled."
fi

# === 🟩 File navigation ===
register_fzf_alias f    'fzf --preview "bat --style=numbers --color=always {}" --bind "enter:execute(nvim {})+abort"' false "Find and open files"

if check_command fd; then
  register_fzf_alias cd   'fd --type d | fzf --prompt="CD into dir > " --bind "enter:execute(cd {})+abort"' true "Fuzzy find and enter subdirectories"
  
  register_fzf_alias code 'fd --type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" -o -name "*.go" -o -name "*.rs" -o -name "*.java" -o -name "*.c" -o -name "*.cpp" -o -name "*.h" \) | fzf --preview "bat --style=numbers --color=always {}" --prompt="Search in code > " --bind "enter:execute(nvim {})+abort"' false "Search in code files (supports multiple programming languages)"
  register_fzf_alias recent 'fd --type f --print0 | xargs -0 ls -lt | head -50 | awk "{print \$NF}" | fzf --preview "bat --style=numbers --color=always {}" --prompt="Recent files > " --bind "enter:execute(nvim {})+abort"' false "Find recently accessed files"
  register_fzf_alias size 'fd --type f | xargs ls -lah | sort -k5 -h | fzf --preview "bat --style=numbers --color=always {9}" --prompt="Files by size > " --bind "enter:execute(nvim {9})+abort"' false "Filter and find files by size"
  register_fzf_alias ext 'fd --type f | grep -E "\.[^.]+$" | sed "s/.*\.//" | sort | uniq -c | sort -nr | fzf --prompt="Select extension > " | awk "{print \$2}" | xargs -I {} fd --type f --extension {}' false "Filter by file extensions"
  
  register_fzf_alias mkdir 'echo -n "New directory name: " && read dirname && mkdir -p "$dirname" && cd "$dirname"' true "Create directory and enter"
  
  # File copy function
  register_fzf_alias cp 'file=$(fd --type f | fzf --prompt="Copy file > ") && [[ -n "$file" ]] && dir=$(fd --type d | fzf --prompt="To directory > ") && [[ -n "$dir" ]] && cp "$file" "$dir" && echo "Copied $file to $dir"' true "Interactive file copy to directory"
  
  # File move function  
  register_fzf_alias mv 'file=$(fd --type f | fzf --prompt="Move file > ") && [[ -n "$file" ]] && dir=$(fd --type d | fzf --prompt="To directory > ") && [[ -n "$dir" ]] && mv "$file" "$dir" && echo "Moved $file to $dir"' true "Interactive file move"
else
  echo "⚠️ fzf-enhance: fd not found. Enhanced file navigation disabled."
fi

# === 🟥 System tools ===
register_fzf_alias kill 'ps -ef | sed 1d | fzf --header="Select process to kill" --bind "enter:execute(kill -9 {1})+abort" --preview "echo PID: {1}"' true "Interactive process termination"

register_fzf_alias port 'lsof -i -P -n | grep LISTEN | fzf --prompt="Kill process on port > " --bind "enter:execute(kill -9 {2})+abort"' false "Find and manage processes using specific ports"
register_fzf_alias top 'ps aux --sort=-%cpu | head -20 | fzf --header="Top processes by CPU" --bind "enter:execute(kill -9 {2})+abort"' true "Interactive system resource monitoring (sorted by CPU)"
register_fzf_alias ping 'echo -e "google.com\n8.8.8.8\n1.1.1.1\nlocalhost" | fzf --prompt="Ping host > " --bind "enter:execute(ping {})+abort"' true "Interactive ping testing"

if [[ -f ~/.ssh/config ]]; then
  register_fzf_alias ss 'grep "^Host " ~/.ssh/config | awk "{print \$2}" | fzf --prompt="SSH to > " --bind "enter:execute(ssh {})+abort"' false "SSH connection management (based on ~/.ssh/config)"
fi

if [[ -f /etc/hosts ]]; then
  register_fzf_alias host 'cat /etc/hosts | grep -v "^#" | fzf --prompt="Edit hosts > " --bind "enter:execute(sudo nvim /etc/hosts)+abort"' true "Edit hosts file entries"
fi

if check_command systemctl; then
  register_fzf_alias service 'systemctl list-units --type=service | fzf --prompt="Manage service > " --bind "enter:execute(systemctl status {1})+abort,ctrl-r:execute(sudo systemctl restart {1})+abort,ctrl-s:execute(sudo systemctl stop {1})+abort"' true "Manage system services (Ctrl+R restart, Ctrl+S stop)"
fi

# === 🟨 General utilities ===
register_fzf_alias h   'history | fzf --tac --preview "echo {}" --bind "enter:execute-silent(echo {} | cut -c 8- | pbcopy)+abort"' false "Copy commands from history"

if check_command zoxide; then
  register_fzf_alias zjump 'zoxide query -l | fzf --prompt="Jump to > " --bind "enter:execute(cd {+})+abort"' false "Jump to known directories (requires zoxide)"
else
  echo "⚠️ fzf-enhance: zoxide not found. Directory jumping (zjump) disabled."
fi

if check_command dict; then
  register_fzf_alias dict 'pbpaste | fzf --preview "dict {}" --bind "enter:abort"' false "Look up words from clipboard (requires dictd)"
else
  echo "⚠️ fzf-enhance: dict not found. Dictionary lookup disabled."
fi

register_fzf_alias env 'env | sort | fzf --prompt="Environment variables > " --preview "echo {}" --bind "enter:execute-silent(echo {} | pbcopy)+abort"' true "Interactive environment variable viewing and copying"
register_fzf_alias path 'echo $PATH | tr ":" "\n" | fzf --prompt="PATH entries > " --bind "enter:execute(ls -la {})+abort"' false "Manage PATH variable entries"

register_fzf_alias config 'echo -e "~/.zshrc\n~/.bashrc\n~/.vimrc\n~/.gitconfig\n~/.ssh/config" | fzf --prompt="Edit config > " --bind "enter:execute(nvim {})+abort"' false "Quick edit common configuration files"
register_fzf_alias dotfile 'fd --hidden --type f --max-depth 1 "^\." ~ | fzf --prompt="Edit dotfile > " --bind "enter:execute(nvim {})+abort"' false "Manage dotfiles"

if check_command brew; then
  register_fzf_alias pkg 'brew list | fzf --prompt="Manage package > " --preview "brew info {}" --bind "enter:execute(brew info {})+abort,ctrl-u:execute(brew uninstall {})+abort"' false "Interactive package management (Ctrl+U uninstall)"
elif check_command apt; then
  register_fzf_alias pkg 'dpkg -l | awk "{print \$2}" | fzf --prompt="Manage package > " --preview "apt show {}" --bind "enter:execute(apt show {})+abort"' false "Interactive package management"
fi

if check_command docker; then
  register_fzf_alias docker 'docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" | fzf --header-lines=1 --prompt="Docker container > " --bind "enter:execute(docker exec -it {1} /bin/bash)+abort,ctrl-s:execute(docker start {1})+abort,ctrl-p:execute(docker stop {1})+abort,ctrl-r:execute(docker restart {1})+abort"' true "Docker container management (Ctrl+S start, Ctrl+P stop, Ctrl+R restart)"
fi

if check_command npm; then
  register_fzf_alias node 'npm list -g --depth=0 2>/dev/null | sed "1d" | fzf --prompt="Node packages > " --bind "enter:execute(npm info {})+abort"' true "Node.js global package management"
fi

# === 🟪 Development tools ===
register_fzf_alias lint 'find . -name "*.py" -o -name "*.js" -o -name "*.ts" | fzf --prompt="Lint file > " --bind "enter:execute(echo \"Linting {}...\" && if [[ {} == *.py ]]; then flake8 {}; elif [[ {} == *.js || {} == *.ts ]]; then eslint {}; fi)+abort"' false "Interactive code linting tools (supports Python, JavaScript, TypeScript)"

if [[ -d "./tests" ]] || [[ -d "./test" ]]; then
  register_fzf_alias test 'find . -path "*/test*" -name "*.py" -o -name "*.js" -o -name "*.ts" | fzf --prompt="Run test > " --bind "enter:execute(echo \"Running test {}...\" && if [[ {} == *.py ]]; then python {}; else npm test {}; fi)+abort"' true "Select and run test files"
fi

if [[ -f "package.json" ]]; then
  register_fzf_alias build 'echo -e "npm run build\nnpm run dev\nnpm run start\nnpm run test" | fzf --prompt="Build command > " --bind "enter:execute({})+abort"' false "Interactive project building (supports npm)"
elif [[ -f "Makefile" ]]; then
  register_fzf_alias build 'grep "^[a-zA-Z0-9_-]*:" Makefile | sed "s/:.*//" | fzf --prompt="Make target > " --bind "enter:execute(make {})+abort"' false "Interactive project building (supports Make)"
fi

# === 🟧 Media and documents ===
register_fzf_alias md 'fd --extension md | fzf --preview "bat --style=numbers --color=always {}" --prompt="Markdown files > " --bind "enter:execute(nvim {})+abort"' false "Preview and edit Markdown files"

if check_command find; then
  register_fzf_alias pdf 'find . -name "*.pdf" | fzf --prompt="PDF files > " --bind "enter:execute(open {})+abort"' false "Find and open PDF files"
  register_fzf_alias img 'find . \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" -o -name "*.bmp" \) | fzf --prompt="Image files > " --bind "enter:execute(open {})+abort"' false "Image file management and viewing"
  register_fzf_alias video 'find . \( -name "*.mp4" -o -name "*.avi" -o -name "*.mkv" -o -name "*.mov" -o -name "*.wmv" \) | fzf --prompt="Video files > " --bind "enter:execute(open {})+abort"' false "Video file management"
fi

register_fzf_alias log 'find /var/log -name "*.log" 2>/dev/null | fzf --prompt="Log files > " --preview "tail -20 {}" --bind "enter:execute(tail -f {})+abort"' false "Interactive system log file viewer"

# === 🆕 Command listing utility ===
register_fzf_alias list 'list_fzf_commands' false "List all registered fzf-enhance commands"

# === 🔄 Plugin management ===
register_fzf_alias update 'echo "🔄 Updating fzf-enhance plugin..." && cd "$FZF_ENHANCE_PLUGIN_DIR" && echo "📁 Plugin directory: $FZF_ENHANCE_PLUGIN_DIR" && git pull && echo "✅ Plugin updated successfully! Please restart your shell or run: source ~/.zshrc"' false "Update fzf-enhance plugin from git repository"

echo "✅ fzf-enhance: All enhanced features loaded successfully!"
echo "💡 Use 'flist' (or 'list' if override enabled) to see all available commands"

