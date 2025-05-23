# fzf-enhance

🎯 An Oh My Zsh plugin to enhance your Git, file, and system workflows using `fzf` + smart aliasing.

## 🔧 Features

### 🟦 Git Tools

- `gco` / `gco_`: Interactively switch branches
- `gbb`: Browse and switch to all branches
- `grm`: Delete local branches
- `gst`, `gcf`: Diff and open modified files
- `gtag`: Checkout tags
- `gcm`: Copy recent commit hash

### 🟩 File Navigation

- `ff`: Find & open files
- `fcd`: Fuzzy cd into subdir
- `groot`: Go to git root

### 🟥 System Tools

- `fkill`: Kill process interactively

### 🟨 General Utilities

- `fh`: Copy previous command from history
- `zf`: Jump to known dirs (`zoxide`)
- `dict`: Lookup clipboard words (`dictd`)

## ⚙️ Optional: override existing OMZ aliases

By default, aliases like `gco` become `gco_` if already defined.  
To override existing ones:

```zsh
export FZF_ENHANCE_OVERRIDE=1

