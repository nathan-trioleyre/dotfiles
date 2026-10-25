#!/usr/bin/env bash

# Update Oh My Zsh, its custom plugins/themes and the tldr cache
set -euo pipefail

NC='\033[0m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

OMZ_DIR="$HOME/.oh-my-zsh"
ZSH_CUSTOM="${OMZ_DIR}/custom"

if [ -d "$OMZ_DIR" ]; then
    log_info "Updating Oh My Zsh..."
    ZSH="$OMZ_DIR" zsh "$OMZ_DIR/tools/upgrade.sh" || log_warning "Oh My Zsh update failed."
fi

for repo in "${ZSH_CUSTOM}"/plugins/*/ "${ZSH_CUSTOM}"/themes/*/; do
    if [ -d "${repo}.git" ]; then
        log_info "Updating $(basename "$repo")..."
        git -C "$repo" pull --ff-only --quiet || log_warning "Failed to update $repo"
    fi
done

if command -v tldr >/dev/null 2>&1; then
    log_info "Updating tldr cache..."
    tldr --update || log_warning "Failed to update tldr cache."
fi

log_success "Update completed. Run: exec zsh"
