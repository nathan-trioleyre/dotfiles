# 🛠️ Dotfiles

## 📦 Included Components

- **Terminal:** [Alacritty](https://alacritty.org/) (Configured with MesloLGS NF for Powerlevel10k, 0.9 opacity, internal padding)
- **Shell:** [Zsh](https://www.zsh.org/) + [Oh My Zsh](https://ohmyz.sh/) + [Powerlevel10k](https://github.com/romkatv/powerlevel10k) theme
- **Zsh Plugins:** `git`, `zsh-autosuggestions`, `zsh-syntax-highlighting`
- **Rust Utilities:**
  - [bat](https://github.com/sharkdp/bat) (A modern alternative to `cat` with syntax highlighting, default theme configured to *TwoDark*)

---

## 🚀 Installation & Restoration

To automatically install and link these configuration files on a new machine, simply run the startup script `install.sh`:

```bash
cd ~/Documents/dev/dotfiles # Or your cloned folder
./install.sh
```

### What the script does automatically:
1. **Oh My Zsh & Theme:** Installs Oh My Zsh if necessary, clones the Powerlevel10k theme, as well as the autosuggestions and syntax highlighting plugins.
2. **Rust & Utilities:** Detects the presence of Rust/Cargo and `bat`, and offers to install them if they are missing.
3. **Backup / Safety:** If a configuration file already exists locally (e.g. `~/.zshrc`), the script renames it to a `.bak` file (e.g., `~/.zshrc.bak.20260710123456`) before creating the symbolic link, guaranteeing **no data loss**.
4. **Symbolic Links:** Creates symbolic links pointing to the repository's configurations:
   - `~/.zshrc` ➔ `zsh/zshrc`
   - `~/.p10k.zsh` ➔ `zsh/p10k.zsh`
   - `~/.config/alacritty/alacritty.toml` ➔ `alacritty/alacritty.toml`
   - `~/.config/bat/config` ➔ `bat/config`

---

## 📂 Repository Structure

```text
dotfiles/
├── alacritty/
│   └── alacritty.toml       # Alacritty graphical configuration
├── bat/
│   └── config               # bat configuration (TwoDark theme, style, etc.)
├── zsh/
│   ├── zshrc                # Zsh configuration (Oh My Zsh, plugins, aliases)
│   └── p10k.zsh             # Powerlevel10k prompt configuration
├── install.sh               # Automated installation script
├── LICENSE                  # Project license
└── README.md                # This documentation
```

---

## 🎨 Useful Customizations

- **Change the `bat` theme:**
  Display available themes using `bat --list-themes`, then modify the `--theme="..."` line in [bat/config](file:///home/ntrioleyre/Documents/dev/dotfiles/bat/config).
- **Configure Powerlevel10k:**
  Run `p10k configure` in your terminal to reconfigure the visual prompt of your Zsh shell. Changes will be saved directly in [zsh/p10k.zsh](file:///home/ntrioleyre/Documents/dev/dotfiles/zsh/p10k.zsh).
- **Add aliases:**
  Modify the [zsh/zshrc](file:///home/ntrioleyre/Documents/dev/dotfiles/zsh/zshrc) file under the `# User configuration` section.