#!/bin/bash

# Colors for logs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Starting Fedora Post-Install Script...${NC}"

# Request sudo password immediately to avoid interruptions later
sudo -v

# --- OPTIMIZE DNF ---
echo -e "${GREEN}⚙️  Optimizing DNF settings...${NC}"
# Use 'tee -a' to append to the file without opening an interactive editor
echo -e "max_parallel_downloads=10\nfastestmirror=True\ndefaultyes=True" | sudo tee -a /etc/dnf/dnf.conf > /dev/null

# --- INITIAL SYSTEM UPDATE ---
echo -e "${GREEN}🔄 Updating repositories...${NC}"
sudo dnf upgrade --refresh -y

# --- BASE TOOLS ---
# Installed first because the font script needs unzip and curl
echo -e "${GREEN}📦 Installing base tools (git, curl, zip)...${NC}"
sudo dnf install unzip p7zip p7zip-plugins unrar git curl wget -y

# --- GIT CONFIG ---
echo -e "${GREEN}🔧 Configuring Git...${NC}"
git config --global user.email "paulovitor.rsd@gmail.com"
git config --global user.name "Paulo Vitor Gomes Rosendo"

# --- RPM FUSION REPOSITORIES ---
echo -e "${GREEN}🔗 Enabling RPM Fusion...${NC}"
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y

# --- MULTIMEDIA CODECS ---
echo -e "${GREEN}🎬 Installing Multimedia Codecs...${NC}"
sudo dnf swap ffmpeg-free ffmpeg --allowerasing -y
sudo dnf group upgrade multimedia -y

# --- FLATPAK AND FLATHUB ---
echo -e "${GREEN}📦 Configuring Flatpak...${NC}"
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# --- PROGRAMMING LANGUAGES ---

# GO
echo -e "${GREEN}🐹 Installing Go...${NC}"
sudo dnf install golang -y

# FNM (Node Manager)
echo -e "${GREEN}🟢 Installing FNM and Node.js...${NC}"
curl -fsSL https://fnm.vercel.app/install | bash
# Load FNM temporarily for the current script session
export PATH="$HOME/.local/share/fnm:$PATH"
eval "`fnm env`"
fnm install --lts

# --- DOCKER ---
echo -e "${GREEN}🐳 Configuring Docker...${NC}"
# Remove old/conflicting versions
sudo dnf remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine -y || true

# Official Repo
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo

# Installation
sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Service
sudo systemctl start docker
sudo systemctl enable docker

# User Group (avoids using sudo for docker commands)
sudo usermod -aG docker $USER

# --- APPLICATIONS ---

# Obsidian
echo -e "${GREEN}📓 Installing Obsidian...${NC}"
flatpak install flathub md.obsidian.Obsidian -y

# Warp Terminal
echo -e "${GREEN}⚡ Installing Warp Terminal...${NC}"
sudo dnf install "https://app.warp.dev/get_warp?package=rpm" -y

# Dbeaver Community
echo -e "${GREEN} Installing Dbeaver Community...${NC}"
flatpak install flathub io.dbeaver.DBeaverCommunity

# Postman
echo -e "${GREEN} Installing Postman...${NC}"
flatpak install flathub com.getpostman.Postman

# VS Code
echo -e "${GREEN}💻 Installing Visual Studio Code...${NC}"
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc\n" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
sudo dnf install code -y

# Spotify
echo -e "${GREEN}🎵 Installing Spotify...${NC}"
flatpak install flathub com.spotify.Client -y

# --- SHELL CONFIGURATION (ZSH) ---
echo -e "${GREEN}🐚 Installing and configuring ZSH...${NC}"
sudo dnf install zsh -y
# Change default shell to Zsh
sudo usermod --shell /bin/zsh $USER

# --- JETBRAINS MONO FONT ---
echo -e "${GREEN}🅰️  Installing JetBrains Mono Font...${NC}"

# Variables
FONT_URL="https://download.jetbrains.com/fonts/JetBrainsMono-2.304.zip"
DEST_DIR="$HOME/.local/share/fonts"
TEMP_DIR=$(mktemp -d)

# Create directory if it doesn't exist
if [ ! -d "$DEST_DIR" ]; then
    echo "📁 Creating directory $DEST_DIR..."
    mkdir -p "$DEST_DIR"
fi

# Download
echo "⬇️  Downloading font..."
curl -L -o "$TEMP_DIR/jetbrains.zip" "$FONT_URL"

# Extract
echo "📦 Extracting..."
unzip -q "$TEMP_DIR/jetbrains.zip" -d "$TEMP_DIR/extracted"

# Move
echo "Moving JetBrainsMono-Regular.ttf to destination..."
mv "$TEMP_DIR/extracted/fonts/ttf/JetBrainsMono-Regular.ttf" "$DEST_DIR/"

# Cache
echo "🔄 Updating font cache..."
fc-cache -f

# Cleanup
echo "🧹 Cleaning up temporary files..."
rm -rf "$TEMP_DIR"

echo -e "${GREEN}✅ Script finished successfully!${NC}"
echo -e "${BLUE}⚠️  Please restart your computer to ensure all changes (Docker, Shell, Fonts) apply correctly.${NC}"