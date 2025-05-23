#!/bin/bash

echo "🚀 Installing fzf-enhance dependencies..."

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    echo "📦 Detected macOS - using Homebrew"
    
    # Check if Homebrew is installed
    if ! command -v brew &> /dev/null; then
        echo "❌ Homebrew not found. Please install Homebrew first:"
        echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi
    
    # Install core dependencies
    echo "🔧 Installing core dependencies..."
    brew install fzf bat fd zoxide ripgrep
    
    # Install optional dependencies
    echo "🔧 Installing optional dependencies..."
    brew install lsof || echo "⚠️ lsof may already be installed"
    brew install dict || echo "⚠️ dict installation optional"
    
    # Docker
    if ! command -v docker &> /dev/null; then
        echo "🐳 Installing Docker Desktop..."
        brew install --cask docker
    fi
    
    # Node.js and npm
    if ! command -v node &> /dev/null; then
        echo "📦 Installing Node.js..."
        brew install node
    fi

elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    echo "📦 Detected Linux"
    
    # Detect package manager
    if command -v apt &> /dev/null; then
        echo "📦 Using apt package manager"
        
        # Update package list
        sudo apt update
        
        # Install core dependencies
        echo "🔧 Installing core dependencies..."
        sudo apt install -y fzf bat fd-find zoxide ripgrep
        
        # Install optional dependencies
        echo "🔧 Installing optional dependencies..."
        sudo apt install -y lsof dictd dict-freedict-eng-deu
        
        # Docker
        if ! command -v docker &> /dev/null; then
            echo "🐳 Installing Docker..."
            sudo apt install -y docker.io
            sudo systemctl enable docker
            sudo systemctl start docker
            sudo usermod -aG docker $USER
            echo "🔄 You may need to logout and login again for Docker permissions"
        fi
        
        # Node.js and npm
        if ! command -v node &> /dev/null; then
            echo "📦 Installing Node.js..."
            curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
            sudo apt install -y nodejs
        fi
        
    elif command -v yum &> /dev/null; then
        echo "📦 Using yum package manager"
        
        # Install EPEL repository first
        sudo yum install -y epel-release
        
        # Install core dependencies
        echo "🔧 Installing core dependencies..."
        sudo yum install -y fzf bat fd-find zoxide ripgrep
        
        # Install optional dependencies
        echo "🔧 Installing optional dependencies..."
        sudo yum install -y lsof dict
        
    elif command -v pacman &> /dev/null; then
        echo "📦 Using pacman package manager (Arch Linux)"
        
        # Install core dependencies
        echo "🔧 Installing core dependencies..."
        sudo pacman -S --noconfirm fzf bat fd zoxide ripgrep
        
        # Install optional dependencies
        echo "🔧 Installing optional dependencies..."
        sudo pacman -S --noconfirm lsof dictd
        
    else
        echo "❌ Unsupported package manager. Please install dependencies manually:"
        echo "   fzf, bat, fd, zoxide, ripgrep, lsof, docker, nodejs, npm"
        exit 1
    fi
    
else
    echo "❌ Unsupported operating system: $OSTYPE"
    exit 1
fi

# Install Node.js packages globally (optional)
if command -v npm &> /dev/null; then
    echo "📦 Installing Node.js development tools..."
    npm install -g eslint prettier || echo "⚠️ Failed to install Node.js tools (may need sudo)"
fi

# Install Python packages (optional)
if command -v pip3 &> /dev/null; then
    echo "🐍 Installing Python development tools..."
    pip3 install --user flake8 black || echo "⚠️ Failed to install Python tools"
fi

echo ""
echo "✅ Installation complete!"
echo ""
echo "🎯 Next steps:"
echo "1. Add fzf-enhance to your Oh My Zsh plugins in ~/.zshrc"
echo "2. Restart your terminal or run: source ~/.zshrc"
echo "3. Try commands like: fgco, fgst, fkill, fdocker"
echo ""
echo "💡 Tip: Set FZF_ENHANCE_OVERRIDE=1 in ~/.zshrc to override existing aliases"

