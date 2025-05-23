# fzf-enhance Feature List

## 📊 Overview

This plugin provides **45 enhanced commands** for command line users, covering 6 major functional categories, significantly improving the efficiency of Git, file management, system management, and development workflows.

---

## 🟦 Git Tools (18 commands)

### Basic Git Operations

- `gco` / `fgco`: Interactive branch checkout
- `gbb` / `fgbb`: Browse and switch to all branches (including remote)
- `gcb` / `fgcb`: Checkout remote branch (creates tracking branch)
- `grm` / `fgrm`: Interactive local branch deletion
- `gtag` / `fgtag`: Checkout tags
- `gcm` / `fgcm`: Copy recent commit hash
- `gcf` / `fgcf`: Browse and edit git repository files
- `gst` / `fgst`: Show and edit modified files (git status)
- `groot` / `fgroot`: Jump to git root directory

### Commit Management

- `gshow` / `fgshow`: Interactive commit details and diff viewer ⚠️
- `greset` / `fgreset`: Interactive reset to specific commit ⚠️
- `gcherry` / `fgcherry`: Interactive cherry-pick commits
- `gstash` / `fgstash`: Interactive stash management (Ctrl+D to delete)

### Remote Repository Management

- `gremote` / `fgremote`: Interactive remote repository information
- `gfetch` / `fgfetch`: Selective fetch from remote branches
- `gpull` / `fgpull`: Select branch for pull operations

### File History

- `glog` / `fglog`: Interactive file git history viewer
- `gblame` / `fgblame`: Select file for blame information

---

## 🟩 File Navigation (9 commands)

### Basic Navigation

- `ff` / `fff`: Find and open files
- `fcd`: Fuzzy find and enter subdirectories

### Advanced Search

- `fcode` / `ffcode`: Search in code files (supports multiple programming languages)
- `frecent` / `ffrecent`: Find recently accessed files
- `fsize` / `ffsize`: Filter and find files by size
- `fext` / `ffext`: Filter by file extensions

### Directory Operations

- `fmkdir`: Create directory and enter
- `fcp`: Interactive file copy to directory
- `fmv`: Interactive file move

---

## 🟥 System Tools (7 commands)

### Process Management

- `fkill`: Interactive process termination
- `fport` / `ffport`: Find and manage processes using specific ports
- `ftop`: Interactive system resource monitoring (sorted by CPU)

### Network Tools

- `fping`: Interactive ping testing
- `fss` / `ffss`: SSH connection management (based on ~/.ssh/config)
- `fhost`: Edit hosts file entries

### Service Management

- `fservice`: Manage system services (Ctrl+R restart, Ctrl+S stop)

---

## 🟨 General Utilities (9 commands)

### Basic Functions

- `fh` / `ffh`: Copy commands from history
- `zjump` / `fzjump`: Jump to known directories (requires zoxide)
- `dict` / `fdict`: Look up words from clipboard (requires dictd)

### Environment Management

- `fenv`: Interactive environment variable viewing and copying
- `fpath` / `ffpath`: Manage PATH variable entries

### Configuration Management

- `fconfig` / `ffconfig`: Quick edit common configuration files
- `fdotfile` / `ffdotfile`: Manage dotfiles

### Package Management

- `fpkg` / `ffpkg`: Interactive package management (Ctrl+U uninstall)
- `fdocker`: Docker container management (Ctrl+S start, Ctrl+P stop, Ctrl+R restart)
- `fnode`: Node.js global package management

---

## 🟪 Development Tools (3 commands)

### Code Quality

- `flint` / `fflint`: Interactive code linting tools (supports Python, JavaScript, TypeScript)
- `ftest`: Select and run test files
- `fbuild` / `ffbuild`: Interactive project building (supports npm, Make)

---

## 🟧 Media and Documents (5 commands)

### Document Operations

- `fmd` / `ffmd`: Preview and edit Markdown files
- `fpdf` / `ffpdf`: Find and open PDF files
- `flog` / `fflog`: Interactive system log file viewer

### Media Files

- `fimg` / `ffimg`: Image file management and viewing
- `fvideo` / `ffvideo`: Video file management

---

## 🆕 Plugin Management (1 command)

### Command Discovery

- `flist` / `fflist`: Interactive list of all registered commands with descriptions

---

## 🎯 Keyboard Shortcut Support

Many commands support additional keyboard shortcuts to improve efficiency:

- **Git Stash**: `Ctrl+D` delete stash
- **System Services**: `Ctrl+R` restart, `Ctrl+S` stop
- **Docker**: `Ctrl+S` start, `Ctrl+P` stop, `Ctrl+R` restart
- **Package Management**: `Ctrl+U` uninstall package
- **Command Browser**: `Enter` copy command name to clipboard

---

## 🔧 Naming Rules

- **Default prefix**: All commands use the `f` prefix (e.g., `fgco`, `fkill`)
- **Override mode**: Set `FZF_ENHANCE_OVERRIDE=1` to remove prefix (e.g., `gco`, but `fkill` still keeps prefix)
- **Forced prefix**: Certain aliases that conflict with system commands will force the `f` prefix even in override mode
- **Conflict detection**: Automatically detects and skips existing aliases

### Forced Prefix List

The following commands will force the `f` prefix due to system command conflicts:

- `fkill` (system kill command)
- `fcd` (system cd command)
- `fcp` (system cp command)
- `fmv` (system mv command)
- `fmkdir` (system mkdir command)
- `ftop` (system top command)
- `fping` (system ping command)
- `fhost` (system host command)
- `fservice` (system service command)
- `fenv` (system env command)
- `fdocker` (docker command)
- `fnode` (node command)
- `ftest` (system test command)

**Example Comparison**:

- Default mode: `ff`, `fgco`, `fkill`, `fconfig`
- Override mode: `f`, `gco`, `fkill`, `config` (note `fkill` still keeps prefix)

---

## ⚡ Performance Optimizations

- **Dependency detection**: Only enables features for installed tools
- **Smart skipping**: Avoids duplicate alias registration
- **Error handling**: Gracefully handles missing dependencies

---

## 🎊 Summary

The fzf-enhance plugin provides comprehensive command-line enhancement features, making your terminal work more efficient and enjoyable! Through interactive interfaces and rich keyboard shortcut support, it significantly improves the efficiency of daily development and system management.
