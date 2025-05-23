# fzf-enhance

🎯 一个增强你 Git、文件和系统工作流的 Oh My Zsh 插件，使用 `fzf` + 智能别名。

## ✨ 特性

### 🟦 Git 工具

**基础功能**

- `gco` / `fgco`: 交互式切换分支
- `gbb` / `fgbb`: 浏览并切换到所有分支（包括远程）
- `gcb` / `fgcb`: 检出远程分支（会创建跟踪分支）
- `grm` / `fgrm`: 交互式删除本地分支
- `gst` / `fgst`: 显示并编辑修改的文件（git status）
- `gcf` / `fgcf`: 浏览并编辑 git 仓库中的文件
- `gtag` / `fgtag`: 检出标签
- `gcm` / `fgcm`: 复制最近提交的哈希值
- `groot` / `fgroot`: 跳转到 git 根目录

**提交相关**

- `gshow` / `fgshow`: 交互式查看提交详情和差异
- `greset` / `fgreset`: 交互式重置到指定提交
- `gcherry` / `fgcherry`: 交互式 cherry-pick 提交
- `gstash` / `fgstash`: 交互式管理 stash（查看、应用、删除 Ctrl+D）

**远程仓库管理**

- `gremote` / `fgremote`: 交互式查看远程仓库信息
- `gfetch` / `fgfetch`: 选择性 fetch 远程分支
- `gpull` / `fgpull`: 选择分支进行 pull 操作

**文件历史**

- `glog` / `fglog`: 交互式查看文件的 git 历史
- `gblame` / `fgblame`: 选择文件查看 blame 信息

### 🟩 文件导航

**基础功能**

- `f` / `ff`: 查找并打开文件
- `fcd`: 模糊查找并进入子目录

**高级搜索**

- `code` / `fcode`: 在代码文件中搜索（支持多种编程语言）
- `recent` / `frecent`: 查找最近访问的文件
- `size` / `fsize`: 按文件大小筛选和查找
- `ext` / `fext`: 按文件扩展名筛选

**目录操作**

- `fmkdir`: 创建目录并进入
- `fcp`: 交互式复制文件到目录
- `fmv`: 交互式移动文件

### 🟥 系统工具

**进程管理**

- `fkill`: 交互式终止进程
- `port` / `fport`: 查找并管理占用特定端口的进程
- `ftop`: 交互式查看系统资源使用情况（按 CPU 排序）

**网络工具**

- `fping`: 交互式 ping 测试
- `ss` / `fss`: SSH 连接管理（基于~/.ssh/config）
- `fhost`: 编辑 hosts 文件条目

**服务管理**

- `fservice`: 管理系统服务（支持 systemctl，Ctrl+R 重启，Ctrl+S 停止）

### 🟨 通用实用工具

**基础功能**

- `h` / `fh`: 从历史记录复制命令
- `zjump` / `fzjump`: 跳转到已知目录（需要 `zoxide`）
- `dict` / `fdict`: 查找剪贴板中的单词（需要 `dictd`）

**环境变量**

- `fenv`: 交互式查看和复制环境变量
- `path` / `fpath`: 管理 PATH 变量中的路径

**配置文件**

- `config` / `fconfig`: 快速编辑常用配置文件
- `dotfile` / `fdotfile`: 管理 dotfiles

**包管理**

- `pkg` / `fpkg`: 交互式包管理（支持 brew、apt，Ctrl+U 卸载）
- `fdocker`: Docker 容器管理（Ctrl+S 启动，Ctrl+P 停止，Ctrl+R 重启）
- `fnode`: Node.js 全局包管理

### 🟪 开发工具

**代码质量**

- `lint` / `flint`: 交互式运行代码检查工具（支持 Python、JavaScript、TypeScript）
- `ftest`: 选择并运行测试文件
- `build` / `fbuild`: 交互式构建项目（支持 npm、Make）

### 🟧 媒体和文档

**文档操作**

- `md` / `fmd`: 预览和编辑 Markdown 文件
- `pdf` / `fpdf`: 查找和打开 PDF 文件
- `log` / `flog`: 交互式查看系统日志文件

**媒体文件**

- `img` / `fimg`: 图片文件管理和查看
- `video` / `fvideo`: 视频文件管理

### 🆕 插件管理

**命令发现**

- `list` / `flist`: 交互式列出所有已注册的命令及其描述

## 📦 依赖

安装以下依赖以获得最佳体验：

**必需依赖**

- `fzf` - 模糊查找器（核心功能）
- `git` - Git 版本控制（Git 相关功能）

**推荐依赖**

- `bat` - 语法高亮的 cat 替代品（文件预览）
- `fd` - 快速文件查找（增强文件导航）
- `zoxide` - 智能目录跳转
- `lsof` - 端口和进程管理
- `docker` - 容器管理功能
- `npm` - Node.js 包管理
- `systemctl` - 系统服务管理（Linux）

**可选依赖**

- `dictd` - 字典服务
- `flake8` - Python 代码检查
- `eslint` - JavaScript/TypeScript 代码检查

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
sudo apt update && sudo apt install -y fzf bat fd-find zoxide lsof

# Node.js相关（可选）
npm install -g eslint

# Python相关（可选）
pip install flake8
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

## 🧠 命名规则

- 默认情况下，所有命令都以 `f` 为前缀（如 `fgco`、`fkill`）以避免别名冲突
- 要覆盖现有命令（如 `gco`、`gst`），请在 `~/.zshrc` 中设置：
  ```zsh
  export FZF_ENHANCE_OVERRIDE=1
  ```
- **系统命令冲突保护**：某些会与系统命令冲突的别名（如 `kill`、`cd`、`mv`、`cp`、`ping`、`top`、`host`、`env`、`mkdir`、`service`、`docker`、`node`、`test`）会强制使用 `f` 前缀，即使在覆盖模式下也是如此
- 插件会自动检测冲突并跳过已存在的别名

### 命名示例

**默认模式**：

- Git: `fgco`, `fgst`, `fgshow`
- 文件: `ff`, `fcode`, `frecent`
- 系统: `fkill`, `fcd`, `fmv`, `fcp` (强制前缀)

**覆盖模式** (`FZF_ENHANCE_OVERRIDE=1`)：

- Git: `gco`, `gst`, `gshow` (无前缀)
- 文件: `f`, `code`, `recent` (无前缀)
- 系统: `fkill`, `fcd`, `fmv`, `fcp` (依然强制前缀，避免系统命令冲突)

## 🎨 使用示例

### Git 工作流

```bash
# 快速切换分支
gco  # 或 fgco

# 查看并编辑修改的文件
gst  # 或 fgst

# 管理stash
gstash  # 或 fgstash (Ctrl+D删除stash)

# 查看提交历史并重置
greset  # 或 fgreset

# 查看文件的git历史
glog  # 或 fglog
```

### 文件操作

```bash
# 查找并打开文件
f   # 或 ff

# 快速跳转目录 (强制前缀)
fcd

# 在代码文件中搜索
code  # 或 fcode

# 按文件大小查找
size  # 或 fsize

# 创建目录并进入 (强制前缀)
fmkdir
```

### 系统管理

```bash
# 终止进程 (强制前缀)
fkill

# 管理端口占用
port  # 或 fport

# 查看系统服务 (强制前缀)
fservice (Ctrl+R重启，Ctrl+S停止)

# SSH连接
ss  # 或 fss

# 跳转到常用目录
zjump  # 或 fzjump
```

### 开发工具

```bash
# 代码检查
lint  # 或 flint

# 运行测试 (强制前缀)
ftest

# 构建项目
build  # 或 fbuild

# Docker管理 (强制前缀)
fdocker (Ctrl+S启动，Ctrl+P停止，Ctrl+R重启)
```

### 配置管理

```bash
# 编辑配置文件
config  # 或 fconfig

# 管理环境变量 (强制前缀)
fenv

# 包管理
pkg  # 或 fpkg (Ctrl+U卸载)
```

### 插件管理

```bash
# 列出所有可用命令
list  # 或 flist

# 交互式浏览命令及其描述
# 按 Enter 复制命令名到剪贴板
```

## 🎯 快捷键说明

许多命令支持额外的快捷键操作：

- **Git Stash**: `Ctrl+D` 删除 stash
- **系统服务**: `Ctrl+R` 重启, `Ctrl+S` 停止
- **Docker**: `Ctrl+S` 启动, `Ctrl+P` 停止, `Ctrl+R` 重启
- **包管理**: `Ctrl+U` 卸载包

## 🔧 自定义

插件使用 `register_fzf_alias` 函数注册命令。你可以通过修改 `fzf-enhance.plugin.zsh` 来自定义命令或添加新功能。

## �� 许可证

MIT License
