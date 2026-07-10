#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Setup colors
NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'

# Get directory of the script
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Functions to check dependencies
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Create backup of a file/directory
backup_file() {
    local target="$1"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        local backup="${target}.bak.$(date +%Y%m%d%H%M%S)"
        log_warning "Backing up existing $target to $backup"
        mv "$target" "$backup"
    elif [ -L "$target" ]; then
        log_info "Removing existing symlink: $target"
        rm "$target"
    fi
}

# Create symlink securely
create_symlink() {
    local source="$1"
    local target="$2"
    
    # Ensure target parent directory exists
    mkdir -p "$(dirname "$target")"
    
    backup_file "$target"
    
    log_info "Symlinking $source -> $target"
    ln -s "$source" "$target"
}

echo -e "${CYAN}=============================================${NC}"
echo -e "${CYAN}    Dotfiles Setup & Installation Script     ${NC}"
echo -e "${CYAN}=============================================${NC}"

# 1. Zsh Setup
if ! command_exists zsh; then
    log_warning "Zsh is not installed. Please install it using your system package manager."
    log_warning "Example: sudo apt install zsh (Debian/Ubuntu) or sudo pacman -S zsh (Arch)"
else
    log_info "Zsh is already installed."
fi

# 2. Oh My Zsh Setup
OMZ_DIR="$HOME/.oh-my-zsh"
if [ ! -d "$OMZ_DIR" ]; then
    log_info "Installing Oh My Zsh..."
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    log_success "Oh My Zsh installed successfully."
else
    log_info "Oh My Zsh is already installed."
fi

# 3. Oh My Zsh Plugins & Themes
ZSH_CUSTOM="${OMZ_DIR}/custom"
mkdir -p "${ZSH_CUSTOM}/plugins" "${ZSH_CUSTOM}/themes"

# Powerlevel10k Theme
if [ ! -d "${ZSH_CUSTOM}/themes/powerlevel10k" ]; then
    log_info "Cloning Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM}/themes/powerlevel10k"
    log_success "Powerlevel10k theme cloned."
else
    log_info "Powerlevel10k theme already present."
fi

# Plugins: zsh-autosuggestions
if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]; then
    log_info "Cloning zsh-autosuggestions plugin..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
    log_success "zsh-autosuggestions plugin cloned."
else
    log_info "zsh-autosuggestions plugin already present."
fi

# Plugins: zsh-syntax-highlighting
if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]; then
    log_info "Cloning zsh-syntax-highlighting plugin..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
    log_success "zsh-syntax-highlighting plugin cloned."
else
    log_info "zsh-syntax-highlighting plugin already present."
fi

# 4. Rust Toolchain Setup
if ! command_exists rustup; then
    echo -e -n "${YELLOW}[QUESTION]${NC} Rust/rustup not found. Would you like to install it? (y/n) "
    read -r install_rust
    if [[ "$install_rust" =~ ^[Yy]$ ]]; then
        log_info "Installing Rust via rustup..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        # Source cargo environment for the current process
        source "$HOME/.cargo/env"
        log_success "Rust installed successfully."
    else
        log_warning "Skipping Rust installation."
    fi
else
    log_info "Rust/rustup is already installed."
fi

# 5. Bat command Setup
if ! command_exists bat && ! command_exists batcat; then
    echo -e -n "${YELLOW}[QUESTION]${NC} bat command not found. Would you like to install it? (y/n) "
    read -r install_bat
    if [[ "$install_bat" =~ ^[Yy]$ ]]; then
        if command_exists cargo; then
            log_info "Installing bat via Cargo..."
            cargo install bat
            log_success "bat installed via Cargo."
        else
            log_warning "Cargo not found. Please install bat manually or install Rust first."
        fi
    fi
else
    log_info "bat command is already installed."
fi

# 6. Alacritty Setup
if ! command_exists alacritty; then
    log_warning "Alacritty is not installed. You can install it via:"
    log_warning " - Debian/Ubuntu: sudo apt install alacritty"
    log_warning " - Arch Linux: sudo pacman -S alacritty"
    log_warning " - Cargo (Rust): cargo install alacritty"
else
    log_info "Alacritty is already installed."
fi

# 7. Symlink Configuration Files
echo ""
log_info "Configuring symlinks..."

create_symlink "${DOTFILES_DIR}/zsh/zshrc" "${HOME}/.zshrc"
create_symlink "${DOTFILES_DIR}/zsh/p10k.zsh" "${HOME}/.p10k.zsh"
create_symlink "${DOTFILES_DIR}/alacritty/alacritty.toml" "${HOME}/.config/alacritty/alacritty.toml"
create_symlink "${DOTFILES_DIR}/bat/config" "${HOME}/.config/bat/config"

echo ""
log_success "Dotfiles configuration completed successfully!"
log_info "Please restart your terminal or run: source ~/.zshrc"
