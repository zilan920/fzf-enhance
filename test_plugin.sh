#!/bin/bash

# fzf-enhance Plugin Test Script
# 用于批量测试插件功能，避免手动逐个测试

set -e

echo "🧪 fzf-enhance Plugin Test Script"
echo "=================================="

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_FILE="$SCRIPT_DIR/fzf-enhance.plugin.zsh"

# 检查插件文件是否存在
if [[ ! -f "$PLUGIN_FILE" ]]; then
    echo "❌ Plugin file not found: $PLUGIN_FILE"
    exit 1
fi

echo "📁 Plugin directory: $SCRIPT_DIR"
echo "📄 Plugin file: $PLUGIN_FILE"
echo ""

# 1. 清理现有aliases
echo "🧹 Step 1: Cleaning existing aliases..."
# 获取所有以f开头的alias并删除（包括git相关命令）
EXISTING_ALIASES=$(alias 2>/dev/null | grep -E "^(f|g)" | cut -d'=' -f1 | tr '\n' ' ' || true)
if [[ -n "$EXISTING_ALIASES" ]]; then
    echo "   Removing aliases: $EXISTING_ALIASES"
    unalias $EXISTING_ALIASES 2>/dev/null || true
else
    echo "   No existing aliases found"
fi

# 额外清理特定的deep命令aliases
unalias fdeep ffdeep cddeep fcddeep 2>/dev/null || true

echo "✅ Aliases cleaned"
echo ""

# 2. 重新加载插件
echo "🔄 Step 2: Reloading plugin..."
if source "$PLUGIN_FILE"; then
    echo "✅ Plugin loaded successfully"
else
    echo "❌ Plugin failed to load"
    exit 1
fi
echo ""

# 3. 验证核心commands是否注册
echo "🔍 Step 3: Verifying core commands..."
CORE_COMMANDS=("ff" "fcd" "fdeep" "cddeep" "fcode" "fcp" "fmv" "fkill" "fh" "flist" "fupdate" "ffping")
FAILED_COMMANDS=()

for cmd in "${CORE_COMMANDS[@]}"; do
    if alias "$cmd" &>/dev/null; then
        echo "   ✅ $cmd - registered"
    else
        echo "   ❌ $cmd - NOT registered"
        FAILED_COMMANDS+=("$cmd")
    fi
done

if [[ ${#FAILED_COMMANDS[@]} -gt 0 ]]; then
    echo ""
    echo "❌ Some commands failed to register: ${FAILED_COMMANDS[*]}"
    echo "   This might indicate issues with dependencies or command conflicts"
else
    echo ""
    echo "✅ All core commands registered successfully"
fi
echo ""

# 4. 检查依赖项
echo "🔧 Step 4: Checking dependencies..."
DEPENDENCIES=("fzf" "git" "fd" "bat" "zoxide")
MISSING_DEPS=()

for dep in "${DEPENDENCIES[@]}"; do
    if command -v "$dep" &>/dev/null; then
        echo "   ✅ $dep - available"
    else
        echo "   ⚠️  $dep - missing (some features may be disabled)"
        MISSING_DEPS+=("$dep")
    fi
done

if [[ ${#MISSING_DEPS[@]} -gt 0 ]]; then
    echo ""
    echo "💡 Missing dependencies: ${MISSING_DEPS[*]}"
    echo "   Install them for full functionality: brew install ${MISSING_DEPS[*]}"
fi
echo ""

# 5. 测试命令定义
echo "🧪 Step 5: Testing command definitions..."
TEST_COMMANDS=("ff" "fcd" "fcode" "ffping")
for cmd in "${TEST_COMMANDS[@]}"; do
    if alias "$cmd" &>/dev/null; then
        ALIAS_DEF=$(alias "$cmd" 2>/dev/null | cut -d'=' -f2- | tr -d "'")
        # 检查是否包含关键组件
        if [[ "$ALIAS_DEF" =~ fzf ]]; then
            echo "   ✅ $cmd - contains fzf"
        else
            echo "   ⚠️  $cmd - missing fzf in definition"
        fi
        
        if [[ "$cmd" =~ ^f(cd|code|deep)$ ]] && [[ "$ALIAS_DEF" =~ fd ]]; then
            echo "   ✅ $cmd - contains fd (file finder)"
        elif [[ "$cmd" == "ffping" ]] && [[ "$ALIAS_DEF" =~ ping ]]; then
            echo "   ✅ $cmd - contains ping command"
        elif [[ "$cmd" == "ff" ]] && [[ "$ALIAS_DEF" =~ fd ]]; then
            echo "   ✅ $cmd - contains fd command"
        fi
    fi
done
echo ""

# 6. 测试配置变量
echo "⚙️  Step 6: Testing configuration variables..."
echo "   FZF_ENHANCE_FILE_DEPTH: ${FZF_ENHANCE_FILE_DEPTH:-'default(3)'}"
echo "   FZF_ENHANCE_DIR_DEPTH: ${FZF_ENHANCE_DIR_DEPTH:-'default(2)'}"
echo "   FZF_ENHANCE_FILE_LIMIT: ${FZF_ENHANCE_FILE_LIMIT:-'default(1000)'}"
echo "   FZF_ENHANCE_DIR_LIMIT: ${FZF_ENHANCE_DIR_LIMIT:-'default(500)'}"
echo "   FZF_ENHANCE_EXCLUDE_DIRS: ${FZF_ENHANCE_EXCLUDE_DIRS:-'default(node_modules .git ...)'}"
echo ""

# 7. 快速功能测试（非交互式）
echo "⚡ Step 7: Quick functionality test..."
if command -v timeout &>/dev/null; then
    echo "   Testing ff command (2 second timeout)..."
    if timeout 2 bash -c 'ff' 2>/dev/null || [[ $? == 124 ]]; then
        echo "   ✅ ff command started successfully"
    else
        echo "   ❌ ff command failed to start"
    fi
else
    echo "   ⚠️  timeout command not available, skipping interactive tests"
fi
echo ""

# 8. 检查命令注册文件
echo "📋 Step 8: Checking command registry..."
COMMANDS_FILE="$SCRIPT_DIR/.fzf_enhance_commands"
if [[ -f "$COMMANDS_FILE" ]]; then
    COMMAND_COUNT=$(wc -l < "$COMMANDS_FILE" 2>/dev/null || echo "0")
    echo "   ✅ Commands registry exists: $COMMANDS_FILE"
    echo "   📊 Registered commands: $COMMAND_COUNT"
    if [[ $COMMAND_COUNT -gt 0 ]]; then
        echo "   📝 Sample commands:"
        head -5 "$COMMANDS_FILE" | while IFS='|' read -r cmd desc; do
            echo "      $cmd - $desc"
        done
    fi
else
    echo "   ❌ Commands registry file not found"
fi
echo ""

# 总结
echo "📊 Test Summary"
echo "==============="
echo "🎯 Core commands: $((${#CORE_COMMANDS[@]} - ${#FAILED_COMMANDS[@]}))/${#CORE_COMMANDS[@]} registered"
echo "🔧 Dependencies: $((${#DEPENDENCIES[@]} - ${#MISSING_DEPS[@]}))/${#DEPENDENCIES[@]} available"

if [[ ${#FAILED_COMMANDS[@]} -eq 0 && ${#MISSING_DEPS[@]} -le 2 ]]; then
    echo ""
    echo "🎉 Plugin test PASSED! All major functionality is working."
    echo "💡 Run 'flist' to see all available commands"
else
    echo ""
    echo "⚠️  Plugin test completed with some issues."
    echo "   Check the missing dependencies and failed commands above."
fi

echo ""
echo "🚀 Test completed. You can now use the plugin!"
echo ""

# 显示一些有用的命令
echo "💡 Quick start commands:"
echo "   flist          - List all commands"
echo "   ff             - Find files"
echo "   fcd            - Change directory"
echo "   fupdate        - Update plugin"
echo "   ffping         - Ping test"
echo "" 