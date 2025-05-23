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

- `fping`: Interactive ping testing
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

### 🆕 Plugin Management

**Command Discovery**

- `list` / `flist`: Interactive list of all registered commands with descriptions

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

# Browse commands interactively with descriptions
# Press Enter to copy command name to clipboard
```

## 🎯 Keyboard Shortcuts

Many commands support additional keyboard shortcuts:

- **Git Stash**: `Ctrl+D` delete stash
- **System Services**: `Ctrl+R` restart, `Ctrl+S` stop
- **Docker**: `Ctrl+S` start, `Ctrl+P` stop, `Ctrl+R` restart
- **Package Management**: `Ctrl+U` uninstall package

## 🔧 Customization

The plugin uses the `register_fzf_alias` function to register commands. You can customize commands or add new features by modifying `fzf-enhance.plugin.zsh`.

## 📄 License

MIT License
