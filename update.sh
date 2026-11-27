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

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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

if [ -f "${DOTFILES_DIR}/.gitmodules" ]; then
    log_info "Updating Git submodules (claude-kit, subagent-tiering)..."
    git -C "$DOTFILES_DIR" submodule update --init --remote --merge --quiet || log_warning "Submodule update failed."

    PY_CMD="$(command -v python3 || command -v python || true)"
    if [ -n "$PY_CMD" ] && [ -f "${HOME}/.claude/claude-kit.json" ] && [ -f "${DOTFILES_DIR}/claude/claude-kit/install.py" ]; then
        log_info "Refreshing claude-kit links..."
        "$PY_CMD" "${DOTFILES_DIR}/claude/claude-kit/install.py" --link || log_warning "claude-kit refresh failed."
    fi
    if [ -d "${HOME}/.claude/subagent-tiering" ] && [ -f "${DOTFILES_DIR}/claude/subagent-tiering/install.sh" ]; then
        log_info "Refreshing subagent-tiering..."
        "${DOTFILES_DIR}/claude/subagent-tiering/install.sh" || log_warning "subagent-tiering refresh failed."
    fi
fi

log_success "Update completed. Run: exec zsh"
