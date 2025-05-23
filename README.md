# fzf-enhance

🎯 An Oh My Zsh plugin that enhances your Git, file, and system workflows using `fzf` + smart aliases.

## ✨ Features

### 🟦 Git Tools

**Basic Operations**

- `gco` / `fgco`: Interactive branch checkout
- `gbb` / `fgbb`: Browse and switch to all branches (including remote)
- `gcb` / `fgcb`: Checkout remote branch (creates tracking branch)
- `grm` / `fgrm`: Interactive local branch deletion
- `gst` / `fgst`: Show and edit modified files (git status)
- `gcf` / `fgcf`: Browse and edit git repository files
- `gtag` / `fgtag`: Checkout tags
- `gcm` / `fgcm`: Copy recent commit hash
- `groot` / `fgroot`: Jump to git root directory

**Commit Management**

- `gshow` / `fgshow`: Interactive commit details and diff viewer
- `greset` / `fgreset`: Interactive reset to specific commit
- `gcherry` / `fgcherry`: Interactive cherry-pick commits
- `gstash` / `fgstash`: Interactive stash management (view, apply, delete with Ctrl+D)

**Remote Repository Management**

- `gremote` / `fgremote`: Interactive remote repository information
- `gfetch` / `fgfetch`: Selective fetch from remote branches
- `gpull` / `fgpull`: Select branch for pull operations

**File History**

- `glog` / `fglog`: Interactive file git history viewer
- `gblame` / `fgblame`: Select file for blame information

### 🟩 File Navigation

**Basic Operations**

- `f` / `ff`: Find and open files
- `fcd`: Fuzzy find and enter subdirectories

**Advanced Search**

- `code` / `fcode`: Search in code files (supports multiple programming languages)
- `recent` / `frecent`: Find recently accessed files
- `size` / `fsize`: Filter and find files by size
- `ext` / `fext`: Filter by file extensions

**Directory Operations**

- `fmkdir`: Create directory and enter
- `fcp`: Interactive file copy to directory
- `fmv`: Interactive file move

### 🟥 System Tools

**Process Management**

- `fkill`: Interactive process termination
- `port` / `fport`: Find and manage processes using specific ports
- `ftop`: Interactive system resource monitoring (sorted by CPU)

**Network Tools**

- `ffping`: Interactive ping testing
- `ss` / `fss`: SSH connection management (based on ~/.ssh/config)
- `fhost`: Edit hosts file entries

**Service Management**

- `fservice`: Manage system services (supports systemctl, Ctrl+R restart, Ctrl+S stop)

### 🟨 General Utilities

**Basic Functions**

- `h` / `fh`: Copy commands from history
- `zjump` / `fzjump`: Jump to known directories (requires `zoxide`)
- `dict` / `fdict`: Look up words from clipboard (requires `dictd`)

**Environment Variables**

- `fenv`: Interactive environment variable viewing and copying
- `path` / `fpath`: Manage PATH variable entries

**Configuration Files**

- `config` / `fconfig`: Quick edit common configuration files
- `dotfile` / `fdotfile`: Manage dotfiles

**Package Management**

- `pkg` / `fpkg`: Interactive package management (supports brew, apt, Ctrl+U uninstall)
- `fdocker`: Docker container management (Ctrl+S start, Ctrl+P stop, Ctrl+R restart)
- `fnode`: Node.js global package management

### 🟪 Development Tools

**Code Quality**

- `lint` / `flint`: Interactive code linting tools (supports Python, JavaScript, TypeScript)
- `ftest`: Select and run test files
- `build` / `fbuild`: Interactive project building (supports npm, Make)

### 🟧 Media and Documents

**Document Operations**

- `md` / `fmd`: Preview and edit Markdown files
- `pdf` / `fpdf`: Find and open PDF files
- `log` / `flog`: Interactive system log file viewer

**Media Files**

- `img` / `fimg`: Image file management and viewing
- `video` / `fvideo`: Video file management

## 🎯 Depth Control System

Many file and directory commands support flexible depth control to optimize performance and search scope. This replaces the old global depth configuration variables with per-command control.

### How Depth Control Works

- **Depth 1**: Search current directory only
- **Depth 2**: Search current directory + 1 level of subdirectories
- **Depth 3**: Search current directory + 2 levels of subdirectories
- **Depth 0**: Unlimited depth (search all subdirectories)

### Commands Supporting Depth Control

#### Directory Navigation

```bash
fcd         # Search current level only (depth 1) - default
fcd 2       # Search up to 2 levels deep
fcd 3       # Search up to 3 levels deep
fcd 0       # Search all levels (unlimited)
```

#### File Search

```bash
ff          # Search current level only (depth 1) - default
ff 2        # Search up to 2 levels deep
ff 3        # Search up to 3 levels deep
ff 0        # Search all levels (unlimited)
```

#### Code File Search

```bash
fcode       # Search code files (default depth 2)
fcode 3     # Search up to 3 levels deep
fcode 4     # Search up to 4 levels deep
fcode 0     # Search all levels (unlimited)
```

#### File Operations

```bash
# File copy with depth control
fcp         # Default depth 2
fcp 3       # Search files and directories up to 3 levels deep
fcp 0       # Search all levels (unlimited)

# File move with depth control
fmv         # Default depth 2
fmv 3       # Search files and directories up to 3 levels deep
fmv 0       # Search all levels (unlimited)
```

#### Advanced File Search

```bash
# Recent files
frecent     # Default depth 2
frecent 3   # Search up to 3 levels deep
frecent 0   # Search all levels (unlimited)

# Files by size
fsize       # Default depth 2
fsize 4     # Search up to 4 levels deep
fsize 0     # Search all levels (unlimited)

# Files by extension
fext        # Default depth 3
fext 5      # Search up to 5 levels deep
fext 0      # Search all levels (unlimited)
```

### Performance Benefits

- **Faster searches**: Limiting depth reduces search time in large projects
- **Relevant results**: Shallow searches often return more relevant files
- **Reduced noise**: Avoid deep dependency directories like `node_modules`
- **Flexible when needed**: Use unlimited depth (0) for comprehensive searches

### Backward Compatibility

Legacy commands are still available:

- `fdeep` - Deep file search (unlimited depth)
- `fcddeep` - Deep directory search (unlimited depth)

### 🟆 Plugin Management

**Command Discovery**

- `list` / `flist`: Interactive command browser with depth control examples and auto-insertion
  - Browse all available commands with detailed descriptions
  - Preview shows depth control examples for file/directory commands
  - **Auto-insertion**: Selected command is automatically inserted into your shell prompt
  - **Clean copy**: Only the command name (no description) is copied to clipboard
  - **Ready to use**: Press Enter to execute or modify the command as needed

**Plugin Updates**

- `update` / `fupdate`: Update plugin from git repository
  - `fupdate` - Update to latest master/main branch
  - `fupdate v1.2.3` - Update to specific tag version
  - `fupdate latest` - Update to latest master/main branch (same as no parameter)

## 📦 Dependencies

Install the following dependencies for the best experience:

**Required Dependencies**

- `fzf` - Fuzzy finder (core functionality)
- `git` - Git version control (Git-related features)

**Recommended Dependencies**

- `bat` - Syntax highlighting cat replacement (file preview)
- `fd` - Fast file finder (enhanced file navigation)
- `zoxide` - Smart directory jumping
- `lsof` - Port and process management
- `docker` - Container management functionality
- `npm` - Node.js package management
- `systemctl` - System service management (Linux)

**Optional Dependencies**

- `dictd` - Dictionary service
- `flake8` - Python code checking
- `eslint` - JavaScript/TypeScript code checking

### Quick Dependency Installation

Run the included preparation script:

```bash
./prepare.sh
```

Or install manually:

```bash
# macOS (Homebrew)
brew install fzf bat fd zoxide

# Ubuntu/Debian
sudo apt update && sudo apt install -y fzf bat fd-find zoxide lsof

# Node.js related (optional)
npm install -g eslint

# Python related (optional)
pip install flake8
```

## 🚀 Installation

### Using Oh My Zsh

1. Clone the repository to your Oh My Zsh custom plugins directory:

   ```bash
   git clone https://github.com/your-repo/fzf-enhance ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-enhance
   ```

2. Add the plugin to your plugins list in `~/.zshrc`:

   ```zsh
   plugins=(... fzf-enhance)
   ```

3. Restart your terminal or run:
   ```bash
   source ~/.zshrc
   ```

### Manual Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/your-repo/fzf-enhance.git
   ```

2. Add to your `~/.zshrc`:
   ```zsh
   source /path/to/fzf-enhance/fzf-enhance.plugin.zsh
   ```

## 🧪 Testing

A comprehensive test script is provided to verify plugin functionality:

```bash
# Run the test script
./test_plugin.sh
```

The test script will:

- Clean existing aliases to avoid conflicts
- Reload the plugin
- Verify all core commands are registered
- Check dependencies
- Test command definitions
- Validate configuration variables
- Perform quick functionality tests
- Generate a detailed report

Use this script whenever you:

- Update the plugin
- Modify configurations
- Troubleshoot issues
- Verify installation

## 🧠 Naming Rules

- By default, all commands use the `f` prefix (e.g., `fgco`, `fkill`) to avoid alias conflicts
- To override existing commands (e.g., `gco`, `gst`), set in `~/.zshrc`:
  ```zsh
  export FZF_ENHANCE_OVERRIDE=1
  ```
- **System Command Conflict Protection**: Certain aliases that would conflict with system commands (such as `kill`, `cd`, `mv`, `cp`, `ping`, `top`, `host`, `env`, `mkdir`, `service`, `docker`, `node`, `test`) will force the `f` prefix even in override mode
- The plugin automatically detects conflicts and skips existing aliases

### Naming Examples

**Default Mode**:

- Git: `fgco`, `fgst`, `fgshow`
- Files: `ff`, `fcode`, `frecent`
- System: `fkill`, `fcd`, `fmv`, `fcp` (forced prefix)

**Override Mode** (`FZF_ENHANCE_OVERRIDE=1`):

- Git: `gco`, `gst`, `gshow` (no prefix)
- Files: `f`, `code`, `recent` (no prefix)
- System: `fkill`, `fcd`, `fmv`, `fcp` (still forced prefix to avoid system command conflicts)

## 🎨 Usage Examples

### Git Workflow

```bash
# Quick branch switching
gco  # or fgco

# View and edit modified files
gst  # or fgst

# Manage stash
gstash  # or fgstash (Ctrl+D to delete stash)

# View commit history and reset
greset  # or fgreset

# View file git history
glog  # or fglog
```

### File Operations

```bash
# Find and open files
f   # or ff

# Quick directory navigation (forced prefix)
fcd

# Search in code files
code  # or fcode

# Find by file size
size  # or fsize

# Create directory and enter (forced prefix)
fmkdir
```

### System Management

```bash
# Terminate processes (forced prefix)
fkill

# Manage port usage
port  # or fport

# View system services (forced prefix)
fservice (Ctrl+R restart, Ctrl+S stop)

# SSH connections
ss  # or fss

# Jump to common directories
zjump  # or fzjump
```

### Development Tools

```bash
# Code checking
lint  # or flint

# Run tests (forced prefix)
ftest

# Build projects
build  # or fbuild

# Docker management (forced prefix)
fdocker (Ctrl+S start, Ctrl+P stop, Ctrl+R restart)
```

### Configuration Management

```bash
# Edit configuration files
config  # or fconfig

# Manage environment variables (forced prefix)
fenv

# Package management
pkg  # or fpkg (Ctrl+U uninstall)
```

### Plugin Management

```bash
# List all available commands
list  # or flist

# Interactive command browser with enhanced features:
# - Browse commands with detailed descriptions
# - See depth control examples in preview
# - Auto-insert selected command into shell prompt
# - Only command name (clean) copied to clipboard

# Update plugin to latest version
update  # or fupdate

# Update to specific tag/version
fupdate v1.2.3

# Update examples
fupdate              # Update to latest master/main
fupdate v2.1.0       # Update to version 2.1.0
fupdate v1.5.2       # Update to version 1.5.2

# If tag update fails, you can check available tags:
# git tag -l
```

## 🎯 Keyboard Shortcuts

Many commands support additional keyboard shortcuts:

- **Git Stash**: `Ctrl+D` delete stash
- **System Services**: `Ctrl+R` restart, `Ctrl+S` stop
- **Docker**: `Ctrl+S` start, `Ctrl+P` stop, `Ctrl+R` restart
- **Package Management**: `Ctrl+U` uninstall package

## ⚡ Performance Optimizations

The plugin has been optimized for performance, especially in large projects with many files:

### Default Performance Settings

- **File search depth**: Limited to 3 levels deep
- **Directory search depth**: Limited to 2 levels deep
- **Results limit**: 1000 files / 500 directories maximum
- **Excluded directories**: `node_modules`, `.git`, `target`, `build`, `dist`, `__pycache__`, `.venv`, `venv`, `.next`, `.nuxt`, `.cache`, `.tmp`, `vendor`

### Quick vs Deep Search Commands

**Fast Commands (Limited Depth)**:

- `ff`, `fcd`, `fcp`, `fmv` - Use depth limits and exclusions for quick results

**Deep Search Commands (Full Search)**:

- `fdeep` - Deep file search (no depth limit, slower)
- `cddeep` - Deep directory search (no depth limit, slower)

### Customizing Performance Settings

Add these environment variables to your `~/.zshrc` **BEFORE** loading the plugin:

```zsh
# Customize search depth
export FZF_ENHANCE_FILE_DEPTH=5        # Default: 3
export FZF_ENHANCE_DIR_DEPTH=3         # Default: 2

# Customize result limits
export FZF_ENHANCE_FILE_LIMIT=2000     # Default: 1000
export FZF_ENHANCE_DIR_LIMIT=1000      # Default: 500

# Customize excluded directories (space-separated)
export FZF_ENHANCE_EXCLUDE_DIRS="node_modules .git build custom_dir"
```

### Performance Tips

1. **For large projects**: Use the default fast commands (`ff`, `fcd`)
2. **When you need everything**: Use deep search commands (`fdeep`, `cddeep`)
3. **Customize exclusions**: Add project-specific large directories to `FZF_ENHANCE_EXCLUDE_DIRS`
4. **Adjust limits**: Increase limits if you need more results, decrease for faster performance

## 🔧 Customization

The plugin uses the `
