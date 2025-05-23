# fzf-enhance Changelog

## v2.0.0 - 2024-01-XX - Major Update

### 🔧 Major Fixes

- **Fixed alias naming rules**: Corrected the naming logic when registering aliases

  - Before: Included `f` prefix at function call time (e.g., `register_fzf_alias ff`)
  - Now: Pass base name, function decides whether to add prefix based on `FZF_ENHANCE_OVERRIDE`
  - Impact: All command naming is now more consistent and predictable

- **Added forced prefix functionality**: Prevents conflicts with system commands
  - Added third parameter to `register_fzf_alias` function for forced prefix
  - 13 aliases that would conflict with system commands will force the `f` prefix
  - Includes: `fkill`, `fcd`, `fcp`, `fmv`, `fmkdir`, `ftop`, `fping`, `fhost`, `fservice`, `fenv`, `fdocker`, `fnode`, `ftest`
  - Even in override mode (`FZF_ENHANCE_OVERRIDE=1`), these commands still maintain the prefix
  - Resolves user concerns about system command conflicts

### 🆕 New Features (35 new commands total)

#### Git Tools Enhancement (9 new commands)

- `gshow/fgshow`: Interactive commit details viewer
- `greset/fgreset`: Interactive reset to specific commit
- `gcherry/fgcherry`: Interactive cherry-pick
- `gstash/fgstash`: Interactive stash management (Ctrl+D to delete)
- `gremote/fgremote`: View remote repository information
- `gfetch/fgfetch`: Selective fetch from remote branches
- `gpull/fgpull`: Select branch for pull operations
- `glog/fglog`: View file git history
- `gblame/fgblame`: File blame information

#### File Navigation Enhancement (7 new commands)

- `code/fcode`: Code file search
- `recent/frecent`: Recently accessed files
- `size/fsize`: Find by file size
- `ext/fext`: Filter by extension
- `mkdir/fmkdir`: Create directory and enter
- `cp/fcp`: Interactive file copy
- `mv/fmv`: Interactive file move

#### System Tools Enhancement (6 new commands)

- `port/fport`: Port usage process management
- `top/ftop`: System resource monitoring (sorted by CPU)
- `ping/fping`: Interactive ping testing
- `ss/fss`: SSH connection management
- `host/fhost`: Edit hosts file
- `service/fservice`: System service management (Ctrl+R restart, Ctrl+S stop)

#### General Utilities Enhancement (8 new commands)

- `env/fenv`: Environment variable viewing and copying
- `path/fpath`: PATH management
- `config/fconfig`: Quick configuration file editing
- `dotfile/fdotfile`: Dotfiles management
- `pkg/fpkg`: Package management (Ctrl+U uninstall)
- `docker/fdocker`: Docker container management (Ctrl+S start, Ctrl+P stop, Ctrl+R restart)
- `node/fnode`: Node.js package management
- Retained: `zjump/fzjump`, `dict/fdict`

#### Development Tools (3 new commands)

- `lint/flint`: Code linting tools
- `test/ftest`: Test file execution
- `build/fbuild`: Project building

#### Media & Documents (5 new commands)

- `md/fmd`: Markdown file management
- `pdf/fpdf`: PDF file search
- `img/fimg`: Image file management
- `video/fvideo`: Video file management
- `log/flog`: System log viewing

### 🎯 Keyboard Shortcut Support

- Git Stash: `Ctrl+D` delete
- System Services: `Ctrl+R` restart, `Ctrl+S` stop
- Docker: `Ctrl+S` start, `Ctrl+P` stop, `Ctrl+R` restart
- Package Management: `Ctrl+U` uninstall

### 📦 Dependency Improvements

- Updated `prepare.sh` installation script with support for more platforms
- Added development tool dependencies (eslint, flake8, etc.)
- Better error handling and dependency detection

### 📚 Documentation Updates

- Updated README.md with complete feature descriptions
- Created FEATURES.md detailed feature list
- Added example-zshrc.sh configuration example
- Created demo.sh and test.sh testing scripts

### 🔄 Naming Rules Explanation

**Default Mode** (no `FZF_ENHANCE_OVERRIDE`):

- Git: `fgco`, `fgst`, `fgshow`
- Files: `ff`, `fcode`, `frecent`
- System: `fkill`, `fcd`, `fmv`, `fcp` (forced prefix)

**Override Mode** (`FZF_ENHANCE_OVERRIDE=1`):

- Git: `gco`, `gst`, `gshow` (no prefix)
- Files: `f`, `code`, `recent` (no prefix)
- System: `fkill`, `fcd`, `fmv`, `fcp` (still forced prefix to avoid system command conflicts)

---

## v1.0.0 - Original Version

### Basic Features

- Basic Git operations (9 commands)
- File navigation (2 commands)
- System tools (1 command)
- Basic utilities (3 commands)

### Total Feature Comparison

- v1.0.0: 15 commands
- v2.0.0: 44 commands (+35 new commands)
- Growth: **193%** feature improvement!
