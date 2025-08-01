#!/bin/bash


# --- Auto-detect yt-dlp ---
YTDLP_BIN="yt-dlp"
if ! command -v yt-dlp >/dev/null 2>&1; then
    echo -e "\033[0;33m[INFO]\033[0m yt-dlp not found in PATH. Attempting to download the latest version..."
    YTDLP_BIN="./yt-dlp"
    if [ ! -f "$YTDLP_BIN" ]; then
        wget -O "$YTDLP_BIN" https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp && chmod +x "$YTDLP_BIN"
        if [ $? -ne 0 ]; then
            echo -e "\033[0;31m[ERROR]\033[0m Failed to download yt-dlp. Please install it manually."
            exit 1
        fi
        echo -e "\033[0;32m[SUCCESS]\033[0m yt-dlp downloaded locally."
    fi
else
    YTDLP_BIN="yt-dlp"
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ASCII Art
echo "
 /\_/\  
( o.o ) 
 > ^ <
"

# Welcome message
echo "======================================================================================================"
echo -e "${GREEN}Welcome User!${NC}"
echo "This tool will download music from URLs in music.txt file in the best audio format."
echo "Songs will be saved to your main Music folder (e.g., ~/Music/July-2025)"
echo "======================================================================================================"

# Create monthly folder in the user's main Music directory
create_monthly_folder() {
    local month_year=$(date +"%B-%Y")  # e.g., "July-2025"
    # Use $HOME/Music to target the main Music folder
    local folder_path="$HOME/Music/$month_year"
    
    if [[ ! -d "$folder_path" ]]; then
        mkdir -p "$folder_path"
        echo -e "${BLUE}Created folder: $folder_path${NC}" >&2
    fi
    
    echo "$folder_path"
}

# Progress bar function
show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((current * width / total))
    
    printf "\r${BLUE}Progress: [${NC}"
    for ((i=0; i<completed; i++)); do printf "█"; done
    for ((i=completed; i<width; i++)); do printf "░"; done
    printf "${BLUE}] ${percentage}%% (${current}/${total})${NC}"
    
    if [[ $current -eq $total ]]; then
        echo ""
    fi
}

# Function to download a single URL
download_url() {
    local url="$1"
    local count="$2"
    local total="$3"
    local folder_path="$4"
    
    echo ""
    echo -e "${YELLOW}Processing Music $count: ${NC}"
    echo -e "${YELLOW}URL: $url${NC}"
    
    # Check if URL contains playlist
    if [[ "$url" == *"list="* ]]; then
        echo -e "${RED}🎵 Playlist detected!${NC}"
        echo "Do you want to download the whole playlist or just the single song?"
        echo "P = Playlist | S = Single song"
        
        # Keep asking until valid input
        while true; do
            read -p "Enter choice (P/S): " choice < /dev/tty
            choice=$(echo "$choice" | tr '[:lower:]' '[:upper:]')
            
            if [[ "$choice" == "P" ]]; then
                echo -e "${GREEN}📦 Downloading whole playlist...${NC}"
                "$YTDLP_BIN" --extract-audio --audio-format mp3 --audio-quality 0 \
                       --output "$folder_path/%(title)s.mp3" \
                       --quiet --progress --newline "$url"
                break
            elif [[ "$choice" == "S" ]]; then
                # Remove playlist parameter to get single video
                cleaned_url=$(echo "$url" | sed 's/[&?]list=[^&]*//g')
                echo -e "${GREEN}🎵 Downloading single song...${NC}"
                "$YTDLP_BIN" --extract-audio --audio-format mp3 --audio-quality 0 \
                       --output "$folder_path/%(title)s.mp3" \
                       --quiet --progress --newline "$cleaned_url"
                break
            else
                echo -e "${RED}❌ Invalid choice. Please enter P or S.${NC}"
            fi
        done
    else
        # Regular single video URL
        echo -e "${GREEN}🎵 Downloading single song...${NC}"
        "$YTDLP_BIN" --extract-audio --audio-format mp3 --audio-quality 0 \
               --output "$folder_path/%(title)s.mp3" \
               --quiet --progress --newline "$url"
    fi
    
    show_progress "$count" "$total"
}

# Check if music.txt exists
if [[ ! -f "music.txt" ]]; then
    echo -e "${RED}❌ Error: music.txt file not found!${NC}"
    exit 1
fi

# Create monthly folder
folder_path=$(create_monthly_folder)

# Count total URLs for progress tracking
total_urls=0
while IFS= read -r music_link; do
    if [[ -n "$music_link" && "$music_link" != "" && ! "$music_link" =~ ^[[:space:]]*# ]]; then
        total_urls=$((total_urls+1))
    fi
done < music.txt

if [[ $total_urls -eq 0 ]]; then
    echo -e "${RED}❌ No valid URLs found in music.txt${NC}"
    exit 1
fi

echo -e "${BLUE}📊 Found $total_urls URLs to process${NC}"
echo -e "${BLUE}💾 Downloads will be saved to: $folder_path${NC}"
echo ""

# Main processing loop
count=0
while IFS= read -r music_link; do
    # Skip empty lines and lines starting with #
    if [[ -n "$music_link" && "$music_link" != "" && ! "$music_link" =~ ^[[:space:]]*# ]]; then
        count=$((count+1))
        download_url "$music_link" "$count" "$total_urls" "$folder_path"
        echo "----------------------------------------"
    fi
done < music.txt

echo ""
echo -e "${GREEN}🎉 All downloads completed!${NC}"
echo -e "${GREEN}📁 Files saved in: $folder_path${NC}"
