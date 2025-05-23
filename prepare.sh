#!/bin/bash
set -e

echo "🔧 Installing fzf-enhance dependencies..."

install() {
  if ! command -v "$1" &>/dev/null; then
    echo "⬇ Installing $1..."
    if command -v brew &>/dev/null; then
      brew install "$1"
    elif command -v apt &>/dev/null; then
      sudo apt update && sudo apt install -y "$1"
    else
      echo "❌ Unsupported package manager. Please install $1 manually."
    fi
  else
    echo "✅ $1 is already installed"
  fi
}

install fzf
install bat
install fd
install zoxide

echo "✅ All dependencies ready!"

