# fzf-enhance

🎯 一个增强你 Git、文件和系统工作流的 Oh My Zsh 插件，使用 `fzf` + 智能别名。

## ✨ 特性

### 🟦 Git 工具

- `gco` / `fgco`: 交互式切换分支
- `gbb` / `fgbb`: 浏览并切换到所有分支（包括远程）
- `gcb` / `fgcb`: 检出远程分支（会创建跟踪分支）
- `grm` / `fgrm`: 交互式删除本地分支
- `gst` / `fgst`: 显示并编辑修改的文件（git status）
- `gcf` / `fgcf`: 浏览并编辑 git 仓库中的文件
- `gtag` / `fgtag`: 检出标签
- `gcm` / `fgcm`: 复制最近提交的哈希值

### 🟩 文件导航

- `ff` / `fff`: 查找并打开文件
- `fcd` / `ffcd`: 模糊查找并进入子目录
- `groot` / `fgroot`: 跳转到 git 根目录

### 🟥 系统工具

- `fkill`: 交互式终止进程

### 🟨 通用实用工具

- `fh` / `ffh`: 从历史记录复制命令
- `zjump` / `fzjump`: 跳转到已知目录（需要 `zoxide`）
- `dict` / `fdict`: 查找剪贴板中的单词（需要 `dictd`）

## 📦 依赖

安装以下依赖以获得最佳体验：

- `fzf` - 模糊查找器
- `bat` - 语法高亮的 cat 替代品
- `fd` - 快速文件查找
- `zoxide` - 智能目录跳转
- `dictd` - 字典服务（可选）

### 快速安装依赖

运行包含的准备脚本：

```bash
./prepare.sh
```

或手动安装：

```bash
# macOS (Homebrew)
brew install fzf bat fd zoxide

# Ubuntu/Debian
sudo apt update && sudo apt install -y fzf bat fd-find zoxide
```

## 🚀 安装

### 使用 Oh My Zsh

1. 克隆仓库到 Oh My Zsh 自定义插件目录：

   ```bash
   git clone https://github.com/your-repo/fzf-enhance ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-enhance
   ```

2. 在 `~/.zshrc` 中添加插件到插件列表：

   ```zsh
   plugins=(... fzf-enhance)
   ```

3. 重启终端或运行：
   ```bash
   source ~/.zshrc
   ```

### 手动安装

1. 克隆仓库：

   ```bash
   git clone https://github.com/your-repo/fzf-enhance.git
   ```

2. 在 `~/.zshrc` 中添加：
   ```zsh
   source /path/to/fzf-enhance/fzf-enhance.plugin.zsh
   ```

## 🧠 命令命名规则

- 默认情况下，所有命令都以 `f` 为前缀（如 `fgco`、`fgst`、`fkill`）以避免别名冲突
- 要覆盖现有命令（如 `gco`、`gst`），请在 `~/.zshrc` 中设置：
  ```zsh
  export FZF_ENHANCE_OVERRIDE=1
  ```
- 插件会自动检测冲突并跳过已存在的别名

## 🎨 使用示例

### Git 工作流

```bash
# 快速切换分支
gco  # 或 fgco

# 查看并编辑修改的文件
gst  # 或 fgst

# 复制提交哈希
gcm  # 或 fgcm
```

### 文件操作

```bash
# 查找并打开文件
ff   # 或 fff

# 快速跳转目录
fcd  # 或 ffcd
```

### 系统管理

```bash
# 终止进程
fkill

# 跳转到常用目录
zjump  # 或 fzjump
```

## 🔧 自定义

插件使用 `register_fzf_alias` 函数注册命令。你可以通过修改 `fzf-enhance.plugin.zsh` 来自定义命令或添加新功能。

## 📝 许可证

MIT License
