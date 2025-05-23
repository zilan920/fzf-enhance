# === Plugin: fzf-enhance ===
# Smart alias registration with conflict avoidance

# === 🎯 Configuration Variables ===
# Set these in your .zshrc before loading the plugin to customize behavior

# Maximum number of results to process (helps with performance)
FZF_ENHANCE_FILE_LIMIT=${FZF_ENHANCE_FILE_LIMIT:-1000}
FZF_ENHANCE_DIR_LIMIT=${FZF_ENHANCE_DIR_LIMIT:-500}

# Directories to exclude from search (space-separated list)
FZF_ENHANCE_EXCLUDE_DIRS=${FZF_ENHANCE_EXCLUDE_DIRS:-"node_modules .git target build dist __pycache__ .venv venv .next .nuxt .cache .tmp vendor"}

# Build exclude parameters for fd command
_get_exclude_dirs() {
  echo "--exclude node_modules --exclude .git --exclude target --exclude build --exclude dist --exclude __pycache__ --exclude .venv --exclude venv --exclude .next --exclude .nuxt --exclude .cache --exclude .tmp --exclude vendor"
}

# Generic function to build fd command with depth control
_build_fd_command() {
  local type="$1"        # f (file) or d (directory)
  local depth="$2"       # search depth (0 for unlimited)
  local extra_args="$3"  # additional fd arguments (optional)
  
  local base_cmd="fd --type $type $(_get_exclude_dirs)"
  
  if [[ $depth -gt 0 ]]; then
    base_cmd="$base_cmd --max-depth $depth"
  fi
  
  if [[ -n "$extra_args" ]]; then
    base_cmd="$base_cmd $extra_args"
  fi
  
  echo "$base_cmd"
}

# Generic function for file/directory selection with depth control
_fzf_select() {
  local type="$1"           # f (file) or d (directory)
  local depth="$2"          # search depth
  local prompt="$3"         # fzf prompt
  local preview_cmd="$4"    # preview command (optional)
  local bind_cmd="$5"       # key binding command (optional)
  local extra_fd_args="$6"  # extra fd arguments (optional)
  local limit_var="$7"      # limit variable name (FZF_ENHANCE_FILE_LIMIT or FZF_ENHANCE_DIR_LIMIT)
  
  local fd_cmd=$(_build_fd_command "$type" "$depth" "$extra_fd_args")
  
  # Get limit value based on variable name
  local limit
  if [[ "$limit_var" == "FZF_ENHANCE_FILE_LIMIT" ]]; then
    limit=$FZF_ENHANCE_FILE_LIMIT
  elif [[ "$limit_var" == "FZF_ENHANCE_DIR_LIMIT" ]]; then
    limit=$FZF_ENHANCE_DIR_LIMIT
  else
    # Fallback to a safe default
    limit=1000
  fi
  
  local fzf_cmd="$fd_cmd | head -$limit | fzf --prompt=\"$prompt\""
  
  if [[ -n "$preview_cmd" ]]; then
    fzf_cmd="$fzf_cmd --preview \"$preview_cmd\""
  fi
  
  if [[ -n "$bind_cmd" ]]; then
    fzf_cmd="$fzf_cmd --bind \"$bind_cmd\""
  fi
  
  eval "$fzf_cmd"
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
  
  # Create enhanced preview content with depth control examples
  local preview_script='
    cmd=$(echo {} | awk "{print \$1}")
    desc=$(echo {} | sed "s/^[[:space:]]*[^[:space:]]*[[:space:]]*//" | fmt -w 50)
    
    echo "🎯 Command: $cmd"
    echo "📝 Description: $desc"
    echo ""
    echo "💡 Depth Control Examples:"
    
    case "$cmd" in
      fcd)
        echo "  fcd      - Search current level only (depth 1)"
        echo "  fcd 2    - Search up to 2 levels deep"
        echo "  fcd 3    - Search up to 3 levels deep"
        echo "  fcd 0    - Search all levels (unlimited)"
        ;;
      ff)
        echo "  ff       - Search current level only (depth 1)"
        echo "  ff 2     - Search up to 2 levels deep"
        echo "  ff 3     - Search up to 3 levels deep"
        echo "  ff 0     - Search all levels (unlimited)"
        ;;
      fcode)
        echo "  fcode    - Search code files (default depth 2)"
        echo "  fcode 3  - Search up to 3 levels deep"
        echo "  fcode 4  - Search up to 4 levels deep"
        echo "  fcode 0  - Search all levels (unlimited)"
        ;;
      frecent|fsize|fcp|fmv)
        echo "  $cmd     - Use default depth (2)"
        echo "  $cmd 3   - Search up to 3 levels deep"
        echo "  $cmd 4   - Search up to 4 levels deep"
        echo "  $cmd 0   - Search all levels (unlimited)"
        ;;
      fext)
        echo "  fext     - Search by extension (default depth 3)"
        echo "  fext 4   - Search up to 4 levels deep"
        echo "  fext 5   - Search up to 5 levels deep"
        echo "  fext 0   - Search all levels (unlimited)"
        ;;
      *)
        echo "  $cmd     - No depth control (uses default behavior)"
        ;;
    esac
    
    echo ""
    echo "⚡ Press Enter to insert command into shell prompt"
    echo "📋 Command will be copied to clipboard (command only)"
  '
  
  # Select command using fzf
  local selected_line
  selected_line=$(printf '%s\n' "${formatted_commands[@]}" | \
    fzf --prompt="fzf-enhance commands > " \
        --header="Select a command to insert into shell prompt" \
        --preview="$preview_script" \
        --preview-window="right:60%" \
        --bind="enter:accept")
  
  # Extract just the command name (first field) from selected line
  if [[ -n "$selected_line" ]]; then
    local selected_cmd=$(echo "$selected_line" | awk '{print $1}')
    
    # Ensure we only have the command name, no extra whitespace or content
    selected_cmd=$(echo "$selected_cmd" | tr -d ' \t\n\r')
    
    # Copy to clipboard if available (command only)
    local clipboard_cmd=""
    if command -v pbcopy &>/dev/null; then
      clipboard_cmd="pbcopy"
    elif command -v xclip &>/dev/null; then
      clipboard_cmd="xclip -selection clipboard"
    elif command -v xsel &>/dev/null; then
      clipboard_cmd="xsel --clipboard --input"
    fi
    
    if [[ -n "$clipboard_cmd" ]]; then
      echo -n "$selected_cmd" | $clipboard_cmd
      echo "📋 Copied '$selected_cmd' to clipboard"
    fi
    
    # Insert command into shell buffer
    if [[ -n "$ZSH_VERSION" ]]; then
      # ZSH: Use print -z to add to command line buffer
      print -z "$selected_cmd"
      echo "✨ '$selected_cmd' inserted into command line. Press Enter to execute or modify as needed."
    elif [[ -n "$BASH_VERSION" ]]; then
      # Bash: Try different methods to insert into command line
      if command -v bind &>/dev/null; then
        # Method 1: Use readline
        printf '\e[2K\r%s' "$selected_cmd"
        echo "✨ '$selected_cmd' inserted into command line."
      else
        echo "✨ Selected command: $selected_cmd"
        echo "💡 Copy and paste this command to execute it."
      fi
    else
      echo "✨ Selected command: $selected_cmd"
      echo "💡 Copy and paste this command to execute it."
    fi
  fi
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

# Enhanced function for interactive directory change with depth control
_fzf_cd() {
  local depth=${1:-1}  # Default depth is 1 (current directory only)
  local selected_dir
  local prompt_text="CD into dir (depth $depth) > "
  
  if [[ $depth -eq 0 ]]; then
    prompt_text="CD into dir (unlimited) > "
  fi
  
  selected_dir=$(_fzf_select "d" "$depth" "$prompt_text" "" "" "" "FZF_ENHANCE_DIR_LIMIT")
  
  if [[ -n "$selected_dir" ]]; then
    cd "$selected_dir"
    echo "📁 Changed to: $(pwd)"
  fi
}

# Enhanced function for file search with depth control
_fzf_file() {
  local depth=${1:-1}  # Default depth is 1 (current directory only)
  local selected_file
  local prompt_text="Find files (depth $depth) > "
  
  if [[ $depth -eq 0 ]]; then
    prompt_text="Find files (unlimited) > "
  fi
  
  selected_file=$(_fzf_select "f" "$depth" "$prompt_text" "bat --style=numbers --color=always {}" "enter:execute(nvim {})+abort" "" "FZF_ENHANCE_FILE_LIMIT")
}

# Enhanced function for code file search with depth control  
_fzf_code() {
  local depth=${1:-2}  # Default depth is 2 for code files
  local selected_file
  local prompt_text="Search code files (depth $depth) > "
  local code_extensions='\( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" -o -name "*.go" -o -name "*.rs" -o -name "*.java" -o -name "*.c" -o -name "*.cpp" -o -name "*.h" \)'
  
  if [[ $depth -eq 0 ]]; then
    prompt_text="Search code files (unlimited) > "
  fi
  
  # Create custom limit for code files (80% of file limit)
  local code_limit=$((FZF_ENHANCE_FILE_LIMIT * 80 / 100))
  
  # Use fd directly since we need special file extensions
  local fd_cmd=$(_build_fd_command "f" "$depth" "$code_extensions")
  selected_file=$(eval "$fd_cmd | head -$code_limit | fzf --preview 'bat --style=numbers --color=always {}' --prompt='$prompt_text' --bind 'enter:execute(nvim {})+abort'")
}

# Enhanced function for recent files with depth control
_fzf_recent() {
  local depth=${1:-2}  # Default depth is 2 for recent files
  local selected_file
  local prompt_text="Recent files (depth $depth) > "
  
  if [[ $depth -eq 0 ]]; then
    prompt_text="Recent files (unlimited) > "
  fi
  
  # Use fd to find files, then sort by modification time
  local fd_cmd=$(_build_fd_command "f" "$depth" "--print0")
  selected_file=$(eval "$fd_cmd | xargs -0 ls -lt | head -50 | awk '{print \$NF}' | fzf --preview 'bat --style=numbers --color=always {}' --prompt='$prompt_text' --bind 'enter:execute(nvim {})+abort'")
}

# Enhanced function for file size search with depth control
_fzf_size() {
  local depth=${1:-2}  # Default depth is 2 for size search
  local selected_file
  local prompt_text="Files by size (depth $depth) > "
  local size_limit=$((FZF_ENHANCE_FILE_LIMIT / 2))
  
  if [[ $depth -eq 0 ]]; then
    prompt_text="Files by size (unlimited) > "
  fi
  
  # Use fd to find files, then sort by size
  local fd_cmd=$(_build_fd_command "f" "$depth")
  selected_file=$(eval "$fd_cmd | head -$size_limit | xargs ls -lah | sort -k5 -h | fzf --preview 'bat --style=numbers --color=always {9}' --prompt='$prompt_text' --bind 'enter:execute(nvim {9})+abort'")
}

# Enhanced function for file copy with depth control
_fzf_copy() {
  local depth=${1:-2}  # Default depth is 2 for file operations
  local selected_file target_dir
  local prompt_text="Copy file (depth $depth) > "
  local limit=$((FZF_ENHANCE_FILE_LIMIT / 2))
  
  if [[ $depth -eq 0 ]]; then
    prompt_text="Copy file (unlimited) > "
  fi
  
  # Select source file
  local fd_cmd=$(_build_fd_command "f" "$depth")
  selected_file=$(eval "$fd_cmd | head -$limit | fzf --prompt='$prompt_text'")
  
  if [[ -n "$selected_file" ]]; then
    # Select target directory with same depth
    local dir_prompt="To directory (depth $depth) > "
    if [[ $depth -eq 0 ]]; then
      dir_prompt="To directory (unlimited) > "
    fi
    
    local dir_limit=$((FZF_ENHANCE_DIR_LIMIT / 2))
    local dir_fd_cmd=$(_build_fd_command "d" "$depth")
    target_dir=$(eval "$dir_fd_cmd | head -$dir_limit | fzf --prompt='$dir_prompt'")
    
    if [[ -n "$target_dir" ]]; then
      cp "$selected_file" "$target_dir" && echo "✅ Copied $selected_file to $target_dir"
    fi
  fi
}

# Enhanced function for file move with depth control
_fzf_move() {
  local depth=${1:-2}  # Default depth is 2 for file operations
  local selected_file target_dir
  local prompt_text="Move file (depth $depth) > "
  local limit=$((FZF_ENHANCE_FILE_LIMIT / 2))
  
  if [[ $depth -eq 0 ]]; then
    prompt_text="Move file (unlimited) > "
  fi
  
  # Select source file
  local fd_cmd=$(_build_fd_command "f" "$depth")
  selected_file=$(eval "$fd_cmd | head -$limit | fzf --prompt='$prompt_text'")
  
  if [[ -n "$selected_file" ]]; then
    # Select target directory with same depth
    local dir_prompt="To directory (depth $depth) > "
    if [[ $depth -eq 0 ]]; then
      dir_prompt="To directory (unlimited) > "
    fi
    
    local dir_limit=$((FZF_ENHANCE_DIR_LIMIT / 2))
    local dir_fd_cmd=$(_build_fd_command "d" "$depth")
    target_dir=$(eval "$dir_fd_cmd | head -$dir_limit | fzf --prompt='$dir_prompt'")
    
    if [[ -n "$target_dir" ]]; then
      mv "$selected_file" "$target_dir" && echo "✅ Moved $selected_file to $target_dir"
    fi
  fi
}

# Function for deep directory search (backward compatibility)
_fzf_cddeep() {
  _fzf_cd 0
}

# Enhanced function for file extension search with depth control
_fzf_ext() {
  local depth=${1:-3}  # Default depth is 3 for extension search
  local selected_ext files_with_ext
  
  # First, find all files and extract extensions
  local fd_cmd=$(_build_fd_command "f" "$depth")
  selected_ext=$(eval "$fd_cmd | head -$FZF_ENHANCE_FILE_LIMIT | grep -E '\.[^.]+$' | sed 's/.*\.//' | sort | uniq -c | sort -nr | fzf --prompt='Select extension > ' | awk '{print \$2}'")
  
  if [[ -n "$selected_ext" ]]; then
    # Find all files with the selected extension
    local ext_fd_cmd=$(_build_fd_command "f" "$depth" "--extension $selected_ext")
    eval "$ext_fd_cmd | fzf --preview 'bat --style=numbers --color=always {}' --prompt='Files with .$selected_ext extension > ' --bind 'enter:execute(nvim {})+abort'"
  fi
}

if check_command fd; then
  register_fzf_alias cd   '_fzf_cd' true "Fuzzy find and enter subdirectories (default: depth 1, use fcd 2, fcd 3, etc. for deeper search)"
  
  # Legacy deep search command for backward compatibility
  register_fzf_alias cddeep '_fzf_cddeep' false "Deep directory search (unlimited depth)"
  
  # Enhanced file commands with depth control
  register_fzf_alias f    '_fzf_file' false "Find and open files (default: depth 1, use ff 2, ff 3, etc. for deeper search)"
  register_fzf_alias code '_fzf_code' false "Search in code files (default: depth 2, use fcode 3, fcode 4, etc. for deeper search)"
  register_fzf_alias recent '_fzf_recent' false "Find recently accessed files (default: depth 2, use frecent 3, frecent 4, etc. for deeper search)"
  register_fzf_alias size '_fzf_size' false "Filter and find files by size (default: depth 2, use fsize 3, fsize 4, etc. for deeper search)"
  register_fzf_alias cp '_fzf_copy' true "Interactive file copy to directory (default: depth 2, use fcp 3, fcp 4, etc. for deeper search)"
  register_fzf_alias mv '_fzf_move' true "Interactive file move (default: depth 2, use fmv 3, fmv 4, etc. for deeper search)"
  
  # Legacy deep search command for files
  register_fzf_alias fdeep 'fd --type f $(_get_exclude_dirs) | fzf --preview "bat --style=numbers --color=always {}" --bind "enter:execute(nvim {})+abort"' false "Deep file search (unlimited depth)"
  
  register_fzf_alias ext '_fzf_ext' false "Filter files by extension (default: depth 3, use fext 4, fext 5, etc. for deeper search)"
  
  register_fzf_alias mkdir 'echo -n "New directory name: " && read dirname && mkdir -p "$dirname" && cd "$dirname"' true "Create directory and enter"
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
register_fzf_alias list 'list_fzf_commands' false "Interactive command browser with depth control examples (auto-inserts selected command into shell)"

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
echo "📖 Tip: Most file/directory commands now support depth control - try adding a number (e.g., fcd 2, ff 3)"

