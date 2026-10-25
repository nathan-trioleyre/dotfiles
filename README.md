# Dotfiles

## Included Components

- **Terminal:** [Alacritty](https://alacritty.org/) (MesloLGS NF font, Snazzy color scheme, 0.9 opacity, internal padding)
- **Shell:** [Zsh](https://www.zsh.org/) + [Oh My Zsh](https://ohmyz.sh/) + [Powerlevel10k](https://github.com/romkatv/powerlevel10k) theme
- **Zsh Plugins:** `git`, `fzf`, `fzf-tab` (with directory previews), `zsh-autosuggestions`, `zsh-syntax-highlighting`
- **CLI Utilities:**
  - [bat](https://github.com/sharkdp/bat) (A modern alternative to `cat` with syntax highlighting, using the terminal palette, aliased as `cat`)
  - [eza](https://github.com/eza-community/eza) (A modern replacement for `ls` with colors and icons, aliased as `ls="eza -F --icons"`)
  - [tealdeer](https://github.com/dbrgn/tealdeer) (A fast, offline implementation of `tldr` in Rust)
  - [fzf](https://github.com/junegunn/fzf) (Fuzzy finder)

---

## Installation & Restoration

To automatically install and link these configuration files on a new machine, simply run the startup script `install.sh`:

```bash
git clone https://github.com/nathan-trioleyre/dotfiles.git ~/Documents/dev/dotfiles
cd ~/Documents/dev/dotfiles
./install.sh
```

Only `git` and `curl` are required beforehand.

### What the script does automatically:
1. **Zsh:** Offers to install Zsh if it is missing, and to make it your default shell.
2. **Oh My Zsh & Theme:** Installs Oh My Zsh if necessary, clones the Powerlevel10k theme, as well as the autosuggestions, syntax highlighting, and fzf-tab plugins.
3. **Font:** Downloads the MesloLGS NF font required by Powerlevel10k and the eza icons.
4. **Utilities:** Detects `bat`, `eza`, `tealdeer` (tldr), `alacritty` and `fzf`, and offers to install the missing ones with your system package manager (`apt`, `pacman`, `dnf` or `brew`). If that fails, it falls back to Cargo, installing Rust first if you agree.
5. **Backup / Safety:** If a configuration file already exists locally (e.g. `~/.zshrc`), the script renames it to a `.bak` file (e.g., `~/.zshrc.bak.20260710123456`) before creating the symbolic link, guaranteeing **no data loss**.
6. **Symbolic Links:** Creates symbolic links pointing to the repository's configurations:
   - `~/.zshenv` ➔ `zsh/zshenv`
   - `~/.zshrc` ➔ `zsh/zshrc`
   - `~/.p10k.zsh` ➔ `zsh/p10k.zsh`
   - `~/.config/alacritty/alacritty.toml` ➔ `alacritty/alacritty.toml`
   - `~/.config/bat/config` ➔ `bat/config`
   - `~/.config/cosmic/com.system76.CosmicSettings.Shortcuts/v1/system_actions` ➔ `cosmic/system_actions` (only on the COSMIC desktop, makes `Super+T` open Alacritty)

The script is idempotent: running it again only does what is missing.

## Updating

```bash
./update.sh
```

Updates Oh My Zsh, the custom plugins and theme, and the tldr cache.

---

## Repository Structure

```text
dotfiles/
├── .github/workflows/
│   └── shellcheck.yml       # Lints the shell scripts on every push
├── alacritty/
│   └── alacritty.toml       # Alacritty configuration (font, colors, window)
├── bat/
│   └── config               # bat configuration (theme, style, etc.)
├── cosmic/
│   └── system_actions       # COSMIC system actions (Super+T opens Alacritty)
├── zsh/
│   ├── zshenv               # Environment variables (PATH, Cargo)
│   ├── zshrc                # Zsh configuration (Oh My Zsh, plugins, aliases)
│   └── p10k.zsh             # Powerlevel10k prompt configuration
├── install.sh               # Automated installation script
├── update.sh                # Updates Oh My Zsh, plugins and tldr cache
├── LICENSE                  # Project license
└── README.md                # This documentation
```

---

## Useful Customizations

- **Change the `bat` theme:**
  Display available themes using `bat --list-themes`, then modify the `--theme="..."` line in [bat/config](bat/config).
- **Configure Powerlevel10k:**
  Run `p10k configure` in your terminal to reconfigure the visual prompt of your Zsh shell. Changes will be saved directly in [zsh/p10k.zsh](zsh/p10k.zsh).
- **Add aliases:**
  Modify the [zsh/zshrc](zsh/zshrc) file under the `# Aliases` section.
- **Machine-specific settings:**
  Put anything that should not be committed (work aliases, tokens, local paths) in `~/.zshrc.local`, which is sourced automatically if it exists.
