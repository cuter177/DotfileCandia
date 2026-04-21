# DotfileCandia
Personal Arch Linux + Hyprland setup.
Minimal, clean and Tokyo Night inspired rice.

---

## 🖥️ Environment
- **WM:** Hyprland
- **Bar:** Waybar (custom modules + Spotify MPRIS + Cava)
- **Terminal:** Kitty
- **Shell:** Zsh + Powerlevel10k
- **Editor:** Neovim (LazyVim)
- **System Info:** Fastfetch

---

## ✨ Features
- Spotify (Flatpak) integration via MPRIS
- Cava audio visualizer in Waybar
- Custom media module
- Bluetooth status indicator
- Volume & brightness popups
- Power menu (wlogout)
- Persistent Hyprland workspaces
- Nerd Font icons
- Tokyo Night color scheme

---

## 📂 Structure
```bash
.config/
├── cava
├── fastfetch
├── hypr
├── kitty
├── nvim
└── waybar
```

---

## 📦 Dependencies

### Base packages (one by one)
```bash
sudo pacman -S hyprland
sudo pacman -S waybar
sudo pacman -S kitty
sudo pacman -S neovim
sudo pacman -S zsh
sudo pacman -S fastfetch
sudo pacman -S playerctl
sudo pacman -S light
sudo pacman -S networkmanager
sudo pacman -S blueman
sudo pacman -S pavucontrol
sudo pacman -S rofi
sudo pacman -S cava
sudo pacman -S eza
sudo pacman -S pacman-contrib
sudo pacman -S ttf-jetbrains-mono-nerd
sudo pacman -S papirus-icon-theme
```

### All at once
```bash
sudo pacman -S \
  hyprland waybar kitty neovim zsh fastfetch \
  playerctl light networkmanager blueman \
  pavucontrol rofi cava eza \
  pacman-contrib ttf-jetbrains-mono-nerd papirus-icon-theme
```

### AUR packages (one by one)
```bash
yay -S hyprpaper
yay -S wlogout
yay -S paru
yay -S pokemon-colorscripts-git
```

### All AUR at once
```bash
yay -S hyprpaper wlogout paru pokemon-colorscripts-git
```

### Nerd Fonts

```bash
# Clonar el repositorio (solo la fuente que necesitas, sin historial completo)
git clone --filter=blob:none --sparse https://github.com/ryanoasis/nerd-fonts.git
cd nerd-fonts

# Instalar JetBrainsMono (la que usa este setup)
git sparse-checkout add patched-fonts/JetBrainsMono
./install.sh JetBrainsMono
```

> Si quieres otra fuente, reemplaza `JetBrainsMono` por el nombre de la carpeta en `patched-fonts/`.
> Lista completa: https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts

### Spotify (Flatpak)
```bash
flatpak install flathub com.spotify.Client
```

#### Optional: Fix scaling issues
```bash
flatpak override --user com.spotify.Client \
  --env=ELECTRON_FORCE_DEVICE_SCALE_FACTOR=0.9
```

---

## 🐧 Other distros (Debian / Fedora)

> ⚠️ This setup was built and tested on **Arch Linux**. Some packages may have different names, older versions, or may not be available in official repos on other distros. Use at your own risk.

### Debian / Ubuntu

Hyprland is **not** in the official Debian/Ubuntu repos. You need to add an external PPA or build from source. The easiest option:

```bash
# Add the Hyprland unofficial PPA (Ubuntu 23.04+)
sudo add-apt-repository ppa:hyprwm/hyprland
sudo apt update
```

Then install base packages:

```bash
sudo apt install -y \
  hyprland waybar kitty neovim zsh \
  playerctl network-manager blueman \
  pavucontrol rofi \
  papirus-icon-theme
```

Packages not available in apt (install manually or via alternative):

```bash
# fastfetch
sudo add-apt-repository ppa:zhangsongcui3371/fastfetch
sudo apt update && sudo apt install fastfetch

# eza
sudo apt install -y gpg
sudo mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
  | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
  | sudo tee /etc/apt/sources.list.d/gierens.list
sudo apt update && sudo apt install -y eza

# cava
sudo apt install -y libfftw3-dev libasound2-dev libncursesw5-dev \
  libpulse-dev libtool automake autoconf-archive pkg-config
git clone https://github.com/karlstav/cava && cd cava
./autogen.sh && ./configure && make && sudo make install

# pokemon-colorscripts
git clone https://gitlab.com/phoneybadger/pokemon-colorscripts.git
cd pokemon-colorscripts && sudo ./install.sh

# light (brightness control)
sudo apt install -y light
```

> `wlogout` and `hyprpaper` may need to be compiled from source on Debian/Ubuntu.

---

### Fedora

Hyprland is available via COPR:

```bash
sudo dnf copr enable solopasha/hyprland
sudo dnf install hyprland
```

Then install base packages:

```bash
sudo dnf install -y \
  waybar kitty neovim zsh fastfetch \
  playerctl NetworkManager blueman \
  pavucontrol rofi cava eza \
  papirus-icon-theme
```

AUR equivalents via COPR or manual install:

```bash
# hyprpaper
sudo dnf copr enable solopasha/hyprland
sudo dnf install hyprpaper

# wlogout
sudo dnf copr enable erikreider/SwayNotificationCenter
sudo dnf install wlogout

# pokemon-colorscripts
git clone https://gitlab.com/phoneybadger/pokemon-colorscripts.git
cd pokemon-colorscripts && sudo ./install.sh

# light
sudo dnf install light
```

> On Fedora, `light` requires adding your user to the `video` group:
> ```bash
> sudo usermod -aG video $USER
> ```

---

### Common for all distros (Debian / Fedora)

These steps are the same regardless of distro:

```bash
# Flatpak (if not installed)
sudo apt install flatpak   # Debian
sudo dnf install flatpak   # Fedora

# Spotify
flatpak install flathub com.spotify.Client

# NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
```

Oh My Zsh, Powerlevel10k, and Zsh plugins install the same way on all distros. See the [Zsh Setup](#-zsh-setup) section.

---

## 🚀 Cloning the repository

### Make sure you have your SSH key configured
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
cat ~/.ssh/id_ed25519.pub
```
> Copy the output and add it at: https://github.com/settings/keys

### Clone via SSH
```bash
git clone git@github.com:cuter177/DotfileCandia.git
cd DotfileCandia
```

---

## 🖥️ Hyprland Setup

### Copy configs
```bash
cp -r DotfileCandia/.config/hypr ~/.config/
cp -r DotfileCandia/.config/kitty ~/.config/
cp -r DotfileCandia/.config/fastfetch ~/.config/
cp -r DotfileCandia/.config/nvim ~/.config/
```

### Reload Hyprland
```bash
hyprctl reload
```

---

## 📊 Waybar Setup

### Copy configs
```bash
cp -r DotfileCandia/.config/waybar ~/.config/
cp -r DotfileCandia/.config/cava ~/.config/
```

### Make scripts executable
```bash
chmod +x ~/.config/waybar/scripts/*.sh
```

### Restart Waybar
```bash
pkill waybar && waybar &
```

---

## 🐚 Zsh Setup

### Install Oh My Zsh
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Install Powerlevel10k
```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

### Install Zsh plugins
```bash
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-syntax-highlighting \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

git clone https://github.com/zsh-users/zsh-history-substring-search \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
```

### Install NVM (Node Version Manager)
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
```

### Copy .zshrc
```bash
cp DotfileCandia/.zshrc ~/
```

### Apply changes
```bash
source ~/.zshrc
```

---

## 🖼️ Preview
![desktop](preview.png)

---

## ⚠️ Notes
- Designed for **Arch Linux**
- Uses **Nerd Fonts** for icons
- Waybar depends on custom scripts located in:
```bash
~/.config/waybar/scripts/
```

---

## 🙏 Credits
This setup is inspired by:
https://github.com/FernuDev/Hypr-dotfiles
Big thanks to **FernuDev** for the original configuration.

---

## 👤 Author
**Alfredo Ramírez Candia**
