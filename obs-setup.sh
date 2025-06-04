#!/bin/bash

# Color codes
GREEN="\033[1;32m"
RED="\033[1;31m"
NC="\033[0m" # No color

echo -e "${GREEN}🔧 Starting Full Setup Script...${NC}"
sleep 2

# Step 1: System Update
echo -e "${GREEN}Step 1: Running sudo apt update...${NC}"
sudo apt update
sleep 2

# Step 2: YouTube 1080p Video Downloader Setup & Download
echo -e "${GREEN}Step 2: YouTube 1080p Video Downloader (MP4) for Linux${NC}"
sleep 2

# Check yt-dlp
if ! command -v yt-dlp &> /dev/null; then
    echo -e "${RED}yt-dlp not found. Installing...${NC}"
    pip3 install --user yt-dlp
    sleep 2
fi

# Check ffmpeg
if ! command -v ffmpeg &> /dev/null; then
    echo -e "${RED}ffmpeg not found. Installing...${NC}"
    sudo apt update
    sudo apt install -y ffmpeg
    sleep 2
fi

# Add yt-dlp to PATH if not already
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
    sleep 2
fi

# Ask for URL
read -p "Enter YouTube video URL: " URL

# Destination folder
DEST="$HOME/Downloads"
echo -e "${GREEN}Downloading to $DEST ...${NC}"
sleep 2

yt-dlp -f "bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]/best[height<=1080][ext=mp4]" \
    -o "$DEST/%(title)s.%(ext)s" "$URL"
sleep 2

echo -e "${GREEN}✅ Download complete. Check your Downloads folder.${NC}"
sleep 2

# Step 3: Install OBS Studio
echo -e "${GREEN}Step 3: Installing obs-studio...${NC}"
sudo apt install -y obs-studio
sleep 2

# Step 4: Restore OBS Settings from GitHub Repo
echo -e "${GREEN}Step 4: Restoring OBS settings from GitHub...${NC}"
sleep 2

# Remove existing local clone if any
if [ -d "obs-studio" ]; then
    echo -e "${RED}⚠️ Deleting existing local 'obs-studio' folder...${NC}"
    rm -rf obs-studio
    sleep 2
fi

echo -e "${GREEN}📥 Cloning OBS settings repo...${NC}"
git clone https://github.com/harrypotterauto/obs-studio.git
sleep 2

cd obs-studio || { echo -e "${RED}❌ Clone failed. Exiting...${NC}"; exit 1; }
sleep 2

if [ -f "obs-backup.tar.gz" ]; then
    echo -e "${GREEN}📦 Extracting OBS backup...${NC}"
    tar -xzvf obs-backup.tar.gz
    sleep 2
else
    echo -e "${RED}❌ obs-backup.tar.gz not found in repo!${NC}"
    exit 1
fi

# Backup old OBS config
if [ -d "$HOME/.config/obs-studio" ]; then
    echo -e "${RED}⚠️ Backing up existing OBS config...${NC}"
    mv "$HOME/.config/obs-studio" "$HOME/.config/obs-studio-backup-$(date +%s)"
    sleep 2
fi

# Move new config
echo -e "${GREEN}📂 Moving new config to ~/.config/obs-studio...${NC}"
mv obs-studio "$HOME/.config/obs-studio"
sleep 2

cd ..
sleep 2

echo -e "${GREEN}✅ OBS settings restored successfully!${NC}"
sleep 2

# Step 5: Anti-Idle Script Setup
echo -e "${GREEN}Step 5: Installing xdotool...${NC}"
sudo apt install -y xdotool
sleep 2

echo -e "${GREEN}Creating anti-idle script at ~/anti-idle.sh...${NC}"
cat << 'EOF' > ~/anti-idle.sh
#!/bin/bash
while true; do
  xdotool mousemove_relative 1 0
  sleep 30
  xdotool mousemove_relative -- -1 0
  sleep 30
done
EOF
chmod +x ~/anti-idle.sh
sleep 2

echo -e "${GREEN}Starting anti-idle script in background...${NC}"
nohup ~/anti-idle.sh > ~/anti-idle.log 2>&1 & disown
sleep 2

# Step 6: Launch OBS
echo -e "${GREEN}Step 6: Launching OBS Studio...${NC}"
obs &
sleep 2

echo -e "${GREEN}✅ All tasks completed successfully! OBS is now running.${NC}"
