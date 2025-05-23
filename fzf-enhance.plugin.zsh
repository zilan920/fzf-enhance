# === Plugin: fzf-enhance ===
# Smart alias registration with conflict avoidance

# === 🎯 Configuration Variables ===
# Set these in your .zshrc before loading the plugin to customize behavior

# Maximum search depth for file operations (default: 3 for files, 2 for directories)
FZF_ENHANCE_FILE_DEPTH=${FZF_ENHANCE_FILE_DEPTH:-3}
FZF_ENHANCE_DIR_DEPTH=${FZF_ENHANCE_DIR_DEPTH:-2}

# Maximum number of results to process (helps with performance)
FZF_ENHANCE_FILE_LIMIT=${FZF_ENHANCE_FILE_LIMIT:-1000}
FZF_ENHANCE_DIR_LIMIT=${FZF_ENHANCE_DIR_LIMIT:-500}

# Directories to exclude from search (space-separated list)
FZF_ENHANCE_EXCLUDE_DIRS=${FZF_ENHANCE_EXCLUDE_DIRS:-"node_modules .git target build dist __pycache__ .venv venv .next .nuxt .cache .tmp vendor"}

# Build exclude parameters for fd command
_get_exclude_dirs() {
  echo "--exclude node_modules --exclude .git --exclude target --exclude build --exclude dist --exclude __pycache__ --exclude .venv --exclude venv --exclude .next --exclude .nuxt --exclude .cache --exclude .tmp --exclude vendor"
}

# Store plugin directory at load time for reliable updates
# Compatible with both zsh and bash
if [[ -n "$ZSH_VERSION" ]]; then
  FZF_ENHANCE_PLUGIN_DIR="$(dirname "${(%):-%x}")"
elif [[ -n "$BASH_VERSION" ]]; then
  FZF_ENHANCE_PLUGIN_DIR="$(dirname "${BASH_SOURCE[0]}")"
else
  # Fallback to current directory
  FZF_ENHANCE_PLUGIN_DIR="$(pwd)"
fi

# Commands registry file
FZF_ENHANCE_COMMANDS_FILE="$FZF_ENHANCE_PLUGIN_DIR/.fzf_enhance_commands"

# Initialize commands file (clear existing content)
echo "" > "$FZF_ENHANCE_COMMANDS_FILE"

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

  # Store command info to file regardless of whether alias exists
  local desc="${description:-No description available}"
  echo "$name|$desc" >> "$FZF_ENHANCE_COMMANDS_FILE"

  # Skip if alias or system command already exists
  if alias "$name" &>/dev/null || command -v "$name" &>/dev/null; then
    echo "⚠️ Skipping alias '$name': already defined"
    return
  fi

  # Use printf to safely escape commands, avoiding complex quote handling
  eval "alias $name='$raw_command'"
}

# Function to list all registered commands
list_fzf_commands() {
  # Check if commands file exists
  if [[ ! -f "$FZF_ENHANCE_COMMANDS_FILE" ]]; then
    echo "❌ Commands registry file not found: $FZF_ENHANCE_COMMANDS_FILE"
    return 1
  fi
  
  # Read commands from file and format them for fzf display
  local formatted_commands=()
  while IFS='|' read -r cmd_name cmd_desc; do
    # Skip empty lines and lines without proper format
    [[ -z "$cmd_name" || -z "$cmd_desc" ]] && continue
    formatted_commands+=("$(printf "%-12s %s" "$cmd_name" "$cmd_desc")")
  done < "$FZF_ENHANCE_COMMANDS_FILE"
  
  # Check if we have any commands
  if [[ ${#formatted_commands[@]} -eq 0 ]]; then
    echo "❌ No commands found in registry"
    return 1
  fi
  
  # Determine clipboard command
  local clipboard_cmd=""
  if command -v pbcopy &>/dev/null; then
    clipboard_cmd="pbcopy"
  elif command -v xclip &>/dev/null; then
    clipboard_cmd="xclip -selection clipboard"
  elif command -v xsel &>/dev/null; then
    clipboard_cmd="xsel --clipboard --input"
  else
    echo "⚠️ No clipboard tool found. Commands will be displayed only."
    # Use fzf without clipboard functionality
    printf '%s\n' "${formatted_commands[@]}" | \
      fzf --prompt="fzf-enhance commands > " \
          --header="Press Enter to select, Ctrl+C to exit" \
          --preview="echo {} | sed 's/^[[:space:]]*[^[:space:]]*[[:space:]]*//' | fmt -w 60"
    return
  fi
  
  # Use fzf to display commands interactively with clipboard support
  printf '%s\n' "${formatted_commands[@]}" | \
    fzf --prompt="fzf-enhance commands > " \
        --header="Press Enter to copy command to clipboard, Ctrl+C to exit" \
        --preview="echo {} | sed 's/^[[:space:]]*[^[:space:]]*[[:space:]]*//' | fmt -w 60" \
        --bind "enter:execute-silent(echo {} | awk '{print $1}' | $clipboard_cmd)+abort"
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

# Function for interactive directory change using zoxide
_fzf_zjump() {
  local selected_dir
  selected_dir=$(zoxide query -l | fzf --prompt="Jump to > ")
  
  if [[ -n "$selected_dir" ]]; then
    cd "$selected_dir"
    echo "🚀 Jumped to: $(pwd)"
  fi
}

# Function for interactive directory change
_fzf_cd() {
  local selected_dir
  selected_dir=$(fd --type d --max-depth $FZF_ENHANCE_DIR_DEPTH --exclude node_modules --exclude .git --exclude target --exclude build --exclude dist --exclude __pycache__ --exclude .venv --exclude venv --exclude .next --exclude .nuxt --exclude .cache --exclude .tmp --exclude vendor | head -$FZF_ENHANCE_DIR_LIMIT | fzf --prompt="CD into dir > ")
  
  if [[ -n "$selected_dir" ]]; then
    cd "$selected_dir"
    echo "📁 Changed to: $(pwd)"
  fi
}

# Function for deep directory search
_fzf_cddeep() {
  local selected_dir
  selected_dir=$(fd --type d --exclude node_modules --exclude .git --exclude target --exclude build --exclude dist --exclude __pycache__ --exclude .venv --exclude venv --exclude .next --exclude .nuxt --exclude .cache --exclude .tmp --exclude vendor | fzf --prompt="CD into dir (deep) > ")
  
  if [[ -n "$selected_dir" ]]; then
    cd "$selected_dir"
    echo "📁 Changed to: $(pwd)"
  fi
}

register_fzf_alias f    'fd --type f --max-depth '$FZF_ENHANCE_FILE_DEPTH' --exclude node_modules --exclude .git --exclude target --exclude build --exclude dist --exclude __pycache__ --exclude .venv --exclude venv --exclude .next --exclude .nuxt --exclude .cache --exclude .tmp --exclude vendor | head -'$FZF_ENHANCE_FILE_LIMIT' | fzf --preview "bat --style=numbers --color=always {}" --bind "enter:execute(nvim {})+abort"' false "Find and open files (optimized with depth limit and exclusions)"

if check_command fd; then
  register_fzf_alias cd   '_fzf_cd' true "Fuzzy find and enter subdirectories (optimized)"
  
  # Deep search alternatives for when you need full search
  register_fzf_alias fdeep 'fd --type f --exclude node_modules --exclude .git --exclude target --exclude build --exclude dist --exclude __pycache__ --exclude .venv --exclude venv --exclude .next --exclude .nuxt --exclude .cache --exclude .tmp --exclude vendor | fzf --preview "bat --style=numbers --color=always {}" --bind "enter:execute(nvim {})+abort"' false "Deep file search (no depth limit)"
  register_fzf_alias cddeep '_fzf_cddeep' false "Deep directory search (no depth limit)"
  
  register_fzf_alias code 'fd --type f --max-depth '$((FZF_ENHANCE_FILE_DEPTH + 1))' --exclude node_modules --exclude .git --exclude target --exclude build --exclude dist --exclude __pycache__ --exclude .venv --exclude venv --exclude .next --exclude .nuxt --exclude .cache --exclude .tmp --exclude vendor \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" -o -name "*.go" -o -name "*.rs" -o -name "*.java" -o -name "*.c" -o -name "*.cpp" -o -name "*.h" \) | head -'$((FZF_ENHANCE_FILE_LIMIT * 80 / 100))' | fzf --preview "bat --style=numbers --color=always {}" --prompt="Search in code > " --bind "enter:execute(nvim {})+abort"' false "Search in code files (optimized)"
  
  register_fzf_alias recent 'fd --type f --max-depth '$FZF_ENHANCE_FILE_DEPTH' --exclude node_modules --exclude .git --exclude target --exclude build --exclude dist --exclude __pycache__ --exclude .venv --exclude venv --exclude .next --exclude .nuxt --exclude .cache --exclude .tmp --exclude vendor --print0 | xargs -0 ls -lt | head -50 | awk "{print \$NF}" | fzf --preview "bat --style=numbers --color=always {}" --prompt="Recent files > " --bind "enter:execute(nvim {})+abort"' false "Find recently accessed files (optimized)"
  
  register_fzf_alias size 'fd --type f --max-depth '$FZF_ENHANCE_FILE_DEPTH' --exclude node_modules --exclude .git --exclude target --exclude build --exclude dist --exclude __pycache__ --exclude .venv --exclude venv --exclude .next --exclude .nuxt --exclude .cache --exclude .tmp --exclude vendor | head -'$((FZF_ENHANCE_FILE_LIMIT / 2))' | xargs ls -lah | sort -k5 -h | fzf --preview "bat --style=numbers --color=always {9}" --prompt="Files by size > " --bind "enter:execute(nvim {9})+abort"' false "Filter and find files by size (optimized)"
  
  register_fzf_alias ext 'fd --type f --max-depth '$FZF_ENHANCE_FILE_DEPTH' --exclude node_modules --exclude .git --exclude target --exclude build --exclude dist --exclude __pycache__ --exclude .venv --exclude venv --exclude .next --exclude .nuxt --exclude .cache --exclude .tmp --exclude vendor | head -'$FZF_ENHANCE_FILE_LIMIT' | grep -E "\.[^.]+$" | sed "s/.*\.//" | sort | uniq -c | sort -nr | fzf --prompt="Select extension > " | awk "{print \$2}" | xargs -I {} fd --type f --max-depth '$FZF_ENHANCE_FILE_DEPTH' --extension {} --exclude node_modules --exclude .git --exclude target --exclude build --exclude dist --exclude __pycache__ --exclude .venv --exclude venv --exclude .next --exclude .nuxt --exclude .cache --exclude .tmp --exclude vendor' false "Filter by file extensions (optimized)"
  
  register_fzf_alias mkdir 'echo -n "New directory name: " && read dirname && mkdir -p "$dirname" && cd "$dirname"' true "Create directory and enter"
  
  # Optimized file copy function
  register_fzf_alias cp 'file=$(fd --type f --max-depth '$FZF_ENHANCE_FILE_DEPTH' --exclude node_modules --exclude .git --exclude target --exclude build --exclude dist --exclude __pycache__ --exclude .venv --exclude venv --exclude .next --exclude .nuxt --exclude .cache --exclude .tmp --exclude vendor | head -'$((FZF_ENHANCE_FILE_LIMIT / 2))' | fzf --prompt="Copy file > ") && [[ -n "$file" ]] && dir=$(fd --type d --max-depth '$FZF_ENHANCE_DIR_DEPTH' --exclude node_modules --exclude .git --exclude target --exclude build --exclude dist --exclude __pycache__ --exclude .venv --exclude venv --exclude .next --exclude .nuxt --exclude .cache --exclude .tmp --exclude vendor | head -'$((FZF_ENHANCE_DIR_LIMIT / 2))' | fzf --prompt="To directory > ") && [[ -n "$dir" ]] && cp "$file" "$dir" && echo "Copied $file to $dir"' true "Interactive file copy to directory (optimized)"
  
  # Optimized file move function  
  register_fzf_alias mv 'file=$(fd --type f --max-depth '$FZF_ENHANCE_FILE_DEPTH' --exclude node_modules --exclude .git --exclude target --exclude build --exclude dist --exclude __pycache__ --exclude .venv --exclude venv --exclude .next --exclude .nuxt --exclude .cache --exclude .tmp --exclude vendor | head -'$((FZF_ENHANCE_FILE_LIMIT / 2))' | fzf --prompt="Move file > ") && [[ -n "$file" ]] && dir=$(fd --type d --max-depth '$FZF_ENHANCE_DIR_DEPTH' --exclude node_modules --exclude .git --exclude target --exclude build --exclude dist --exclude __pycache__ --exclude .venv --exclude venv --exclude .next --exclude .nuxt --exclude .cache --exclude .tmp --exclude vendor | head -'$((FZF_ENHANCE_DIR_LIMIT / 2))' | fzf --prompt="To directory > ") && [[ -n "$dir" ]] && mv "$file" "$dir" && echo "Moved $file to $dir"' true "Interactive file move (optimized)"
else
  echo "⚠️ fzf-enhance: fd not found. Enhanced file navigation disabled."
fi

# === 🟥 System tools ===
register_fzf_alias kill 'ps -ef | sed 1d | fzf --header="Select process to kill" --bind "enter:execute(kill -9 {1})+abort" --preview "echo PID: {1}"' true "Interactive process termination"

register_fzf_alias port 'lsof -i -P -n | grep LISTEN | fzf --prompt="Kill process on port > " --bind "enter:execute(kill -9 {2})+abort"' false "Find and manage processes using specific ports"

# Detect OS and use appropriate ps command for top processes
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS/BSD ps
  register_fzf_alias top 'ps aux -r | head -20 | fzf --header="Top processes by CPU" --bind "enter:execute(kill -9 {2})+abort"' true "Interactive system resource monitoring (sorted by CPU)"
else
  # Linux ps with --sort option
  register_fzf_alias top 'ps aux --sort=-%cpu | head -20 | fzf --header="Top processes by CPU" --bind "enter:execute(kill -9 {2})+abort"' true "Interactive system resource monitoring (sorted by CPU)"
fi

register_fzf_alias fping 'echo -e "google.com\n8.8.8.8\n1.1.1.1\nlocalhost" | fzf --prompt="Ping host > " --bind "enter:execute(ping {})+abort"' false "Interactive ping testing"

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
  register_fzf_alias zjump '_fzf_zjump' false "Jump to known directories (requires zoxide)"
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
# Function to update the plugin
_fzf_enhance_update() {
  local tag="$1"
  
  echo "🔄 Updating fzf-enhance plugin..."
  echo "📁 Plugin directory: $FZF_ENHANCE_PLUGIN_DIR"
  
  cd "$FZF_ENHANCE_PLUGIN_DIR" || {
    echo "❌ Failed to change to plugin directory: $FZF_ENHANCE_PLUGIN_DIR"
    return 1
  }
  
  # Check if we're in a git repository
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "❌ Plugin directory is not a git repository"
    return 1
  fi
  
  if [[ -n "$tag" ]]; then
    echo "🏷️  Checking out tag: $tag"
    
    # Fetch all tags from remote
    echo "📡 Fetching tags..."
    if ! git fetch --tags; then
      echo "❌ Failed to fetch tags"
      return 1
    fi
    
    # Check if tag exists
    if ! git tag -l | grep -q "^$tag$"; then
      echo "❌ Tag '$tag' not found. Available tags:"
      git tag -l | head -10
      if [[ $(git tag -l | wc -l) -gt 10 ]]; then
        echo "... and $(($(git tag -l | wc -l) - 10)) more"
      fi
      return 1
    fi
    
    # Checkout the specified tag
    if git checkout "$tag"; then
      echo "✅ Successfully checked out tag: $tag"
    else
      echo "❌ Failed to checkout tag: $tag"
      return 1
    fi
  else
    echo "🔄 Pulling latest changes from master/main..."
    
    # Try to determine the default branch
    local default_branch
    default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
    
    if [[ -z "$default_branch" ]]; then
      # Fallback: try common branch names
      if git show-ref --verify --quiet refs/remotes/origin/main; then
        default_branch="main"
      elif git show-ref --verify --quiet refs/remotes/origin/master; then
        default_branch="master"
      else
        default_branch="master"  # Final fallback
      fi
    fi
    
    echo "📡 Switching to $default_branch and pulling..."
    
    # Switch to default branch and pull
    if git checkout "$default_branch" && git pull origin "$default_branch"; then
      echo "✅ Successfully updated to latest $default_branch"
    else
      echo "❌ Failed to update. Trying simple git pull..."
      if git pull; then
        echo "✅ Successfully updated using git pull"
      else
        echo "❌ Failed to update plugin"
        return 1
      fi
    fi
  fi

  cd -
  
  echo "✅ Plugin updated successfully!"
  echo "💡 Please restart your shell or run: source ~/.zshrc"
  echo ""
  echo "📋 Usage:"
  echo "  fupdate          - Update to latest master/main"
  echo "  fupdate v1.2.3   - Update to specific tag"
}

register_fzf_alias update '_fzf_enhance_update' false "Update fzf-enhance plugin from git repository (use 'fupdate [tag]' for specific version)"

echo "💡 Use 'flist' (or 'list' if override enabled) to see all available commands"

