#!/usr/bin/env bash

# Exit on errors, unset variables and failed pipes
set -euo pipefail

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

# Ask a yes/no question, succeed on "y"
ask() {
    local reply
    echo -e -n "${YELLOW}[QUESTION]${NC} $1 (y/n) "
    read -r reply
    [[ "$reply" =~ ^[Yy]$ ]]
}

# Functions to check dependencies
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect the system package manager
PKG_MANAGER=""
for pm in apt-get pacman dnf brew; do
    if command_exists "$pm"; then
        PKG_MANAGER="$pm"
        break
    fi
done
APT_UPDATED=0

# Install packages with the system package manager
pkg_install() {
    case "$PKG_MANAGER" in
        apt-get)
            if [ "$APT_UPDATED" -eq 0 ]; then
                sudo apt-get update && APT_UPDATED=1
            fi
            sudo apt-get install -y "$@"
            ;;
        pacman) sudo pacman -S --needed --noconfirm "$@" ;;
        dnf) sudo dnf install -y "$@" ;;
        brew) brew install "$@" ;;
        *) return 1 ;;
    esac
}

# Make cargo available, offering to install Rust via rustup
ensure_cargo() {
    if command_exists cargo; then
        return 0
    fi
    if ask "Cargo is required as a fallback but Rust/rustup is not installed. Install it?"; then
        log_info "Installing Rust via rustup..."
        # PATH is handled by zsh/zshenv, so rustup must not edit shell files
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
        # shellcheck source=/dev/null
        source "$HOME/.cargo/env"
        log_success "Rust installed successfully."
        return 0
    fi
    log_warning "Skipping Rust installation."
    return 1
}

# Install a tool with the package manager, falling back to cargo
# Usage: install_tool <package> <crate>
install_tool() {
    local package="$1"
    local crate="$2"

    if [ -n "$PKG_MANAGER" ]; then
        log_info "Installing $package via $PKG_MANAGER..."
        if pkg_install "$package"; then
            log_success "$package installed via $PKG_MANAGER."
            return 0
        fi
        log_warning "Could not install $package via $PKG_MANAGER, trying Cargo."
    fi

    if ensure_cargo; then
        log_info "Installing $crate via Cargo..."
        cargo install --locked "$crate"
        log_success "$crate installed via Cargo."
        return 0
    fi

    log_warning "Please install $package manually."
    return 1
}

# Create backup of a file/directory
backup_file() {
    local target="$1"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        local backup
        backup="${target}.bak.$(date +%Y%m%d%H%M%S)"
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

    if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
        log_info "Symlink already up to date: $target"
        return 0
    fi

    # Ensure target parent directory exists
    mkdir -p "$(dirname "$target")"

    backup_file "$target"

    log_info "Symlinking $source -> $target"
    ln -s "$source" "$target"
}

echo -e "${CYAN}=============================================${NC}"
echo -e "${CYAN}    Dotfiles Setup & Installation Script     ${NC}"
echo -e "${CYAN}=============================================${NC}"

# 0. Required tools
for cmd in git curl; do
    if ! command_exists "$cmd"; then
        log_error "$cmd is required. Please install it with your system package manager."
        exit 1
    fi
done

# 1. Zsh Setup
if ! command_exists zsh; then
    if ask "Zsh is not installed. Install it?" && pkg_install zsh; then
        log_success "Zsh installed successfully."
    else
        log_error "Zsh is required. Please install it with your system package manager."
        exit 1
    fi
else
    log_info "Zsh is already installed."
fi

ZSH_PATH="$(command -v zsh)"
if [ "$(basename "${SHELL:-}")" != "zsh" ]; then
    if ask "Your default shell is ${SHELL:-unknown}. Make zsh your default shell?"; then
        chsh -s "$ZSH_PATH"
        log_success "Default shell changed to $ZSH_PATH (effective at next login)."
    fi
else
    log_info "Zsh is already the default shell."
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

# Clone a plugin or theme if it is not already present
# Usage: clone_repo <name> <url> <destination>
clone_repo() {
    local name="$1"
    local url="$2"
    local dest="$3"
    if [ ! -d "$dest" ]; then
        log_info "Cloning $name..."
        git clone --depth=1 "$url" "$dest"
        log_success "$name cloned."
    else
        log_info "$name already present."
    fi
}

clone_repo "Powerlevel10k theme" https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM}/themes/powerlevel10k"
clone_repo "zsh-autosuggestions plugin" https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
clone_repo "zsh-syntax-highlighting plugin" https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
clone_repo "fzf-tab plugin" https://github.com/Aloxaf/fzf-tab "${ZSH_CUSTOM}/plugins/fzf-tab"

# 4. MesloLGS NF font (required by Powerlevel10k, Alacritty and eza icons)
if [ "$(uname)" = "Darwin" ]; then
    FONT_DIR="$HOME/Library/Fonts"
else
    FONT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"
fi
FONT_URL="https://github.com/romkatv/powerlevel10k-media/raw/master"
mkdir -p "$FONT_DIR"
fonts_added=0
for style in Regular Bold Italic "Bold Italic"; do
    font_file="MesloLGS NF ${style}.ttf"
    if [ ! -f "$FONT_DIR/$font_file" ]; then
        log_info "Downloading $font_file..."
        curl -fsSL -o "$FONT_DIR/$font_file" "$FONT_URL/${font_file// /%20}"
        fonts_added=1
    fi
done
if [ "$fonts_added" -eq 1 ]; then
    if command_exists fc-cache; then
        fc-cache -f "$FONT_DIR" >/dev/null
    fi
    log_success "MesloLGS NF font installed."
else
    log_info "MesloLGS NF font already installed."
fi

# 5. Bat command Setup
if ! command_exists bat && ! command_exists batcat; then
    if ask "bat command not found. Would you like to install it?"; then
        install_tool bat bat || true
    fi
else
    log_info "bat command is already installed."
fi

# 6. Eza command Setup
if ! command_exists eza; then
    if ask "eza command not found. Would you like to install it?"; then
        install_tool eza eza || true
    fi
else
    log_info "eza command is already installed."
fi

# 7. Tealdeer command Setup
if ! command_exists tldr; then
    if ask "tldr command (tealdeer) not found. Would you like to install it?"; then
        if install_tool tealdeer tealdeer; then
            log_info "Updating tldr cache..."
            if command_exists tldr; then
                tldr --update || log_warning "Failed to update tldr cache."
            else
                log_warning "tldr executable not found in PATH to update cache."
            fi
        fi
    fi
else
    log_info "tldr command (tealdeer) is already installed."
fi

# 8. Alacritty Setup
if ! command_exists alacritty; then
    if ask "Alacritty is not installed. Would you like to install it?"; then
        install_tool alacritty alacritty || true
    fi
else
    log_info "Alacritty is already installed."
fi

# 9. fzf Setup
if ! command_exists fzf; then
    if ask "fzf command not found. Would you like to install it?"; then
        if [ -n "$PKG_MANAGER" ] && pkg_install fzf; then
            log_success "fzf installed via $PKG_MANAGER."
        else
            clone_repo "fzf repository" https://github.com/junegunn/fzf.git "$HOME/.fzf"
            log_info "Installing fzf binary..."
            "$HOME/.fzf/install" --bin
            log_success "fzf installed successfully."
        fi
    fi
else
    log_info "fzf command is already installed."
fi

# 10. Symlink Configuration Files
echo ""
log_info "Configuring symlinks..."

create_symlink "${DOTFILES_DIR}/zsh/zshenv" "${HOME}/.zshenv"
create_symlink "${DOTFILES_DIR}/zsh/zshrc" "${HOME}/.zshrc"
create_symlink "${DOTFILES_DIR}/zsh/p10k.zsh" "${HOME}/.p10k.zsh"
create_symlink "${DOTFILES_DIR}/alacritty/alacritty.toml" "${HOME}/.config/alacritty/alacritty.toml"
create_symlink "${DOTFILES_DIR}/bat/config" "${HOME}/.config/bat/config"

echo ""
log_success "Dotfiles configuration completed successfully!"
log_info "Please restart your terminal or run: exec zsh"
