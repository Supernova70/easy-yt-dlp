#!/bin/bash

# Enhanced Easy YT-DLP Music Downloader
# Version: 2.0
# Features: Configuration, Multiple formats, Advanced organization, Smart features

# --- Configuration File Support ---
CONFIG_FILE="config.ini"
HISTORY_FILE="download_history.log"
ERROR_LOG="error.log"

# Default configuration
DEFAULT_AUDIO_FORMAT="mp3"
DEFAULT_AUDIO_QUALITY="0"
DEFAULT_VIDEO_FORMAT="mp4"
DEFAULT_ORGANIZATION="monthly"  # monthly, artist, album, year
DEFAULT_NAMING_PATTERN="%(title)s"
DEFAULT_MAX_RETRIES="3"
DEFAULT_PARALLEL_DOWNLOADS="1"
DEFAULT_BACKUP_ENABLED="false"

# Load or create configuration
load_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        create_default_config
    fi
    
    source "$CONFIG_FILE"
    
    # Set defaults if not found in config
    AUDIO_FORMAT=${AUDIO_FORMAT:-$DEFAULT_AUDIO_FORMAT}
    AUDIO_QUALITY=${AUDIO_QUALITY:-$DEFAULT_AUDIO_QUALITY}
    VIDEO_FORMAT=${VIDEO_FORMAT:-$DEFAULT_VIDEO_FORMAT}
    ORGANIZATION=${ORGANIZATION:-$DEFAULT_ORGANIZATION}
    NAMING_PATTERN=${NAMING_PATTERN:-$DEFAULT_NAMING_PATTERN}
    MAX_RETRIES=${MAX_RETRIES:-$DEFAULT_MAX_RETRIES}
    PARALLEL_DOWNLOADS=${PARALLEL_DOWNLOADS:-$DEFAULT_PARALLEL_DOWNLOADS}
    BACKUP_ENABLED=${BACKUP_ENABLED:-$DEFAULT_BACKUP_ENABLED}
}

create_default_config() {
    cat > "$CONFIG_FILE" << EOF
# Easy YT-DLP Configuration File
# Edit these values to customize your download experience

# Audio Settings
AUDIO_FORMAT="mp3"          # mp3, m4a, flac, opus, wav
AUDIO_QUALITY="0"           # 0 (best), 1-9 (worst), or bitrate like 320K
VIDEO_FORMAT="mp4"          # mp4, webm, mkv, avi

# Organization Settings  
ORGANIZATION="monthly"      # monthly, artist, album, year, flat
NAMING_PATTERN="%(artist)s - %(title)s"  # %(title)s, %(artist)s - %(title)s, %(album)s/%(title)s
DOWNLOAD_THUMBNAILS="false" # true/false
DOWNLOAD_SUBTITLES="false"  # true/false

# Performance Settings
MAX_RETRIES="3"             # Number of retry attempts for failed downloads
PARALLEL_DOWNLOADS="1"      # Number of simultaneous downloads (1-5)
MAX_SPEED=""                # Max download speed (e.g., 1M, 500K, leave empty for unlimited)

# Advanced Settings
PROXY_URL=""                # Proxy URL if needed
BACKUP_ENABLED="false"      # Enable automatic backup to cloud storage
NOTIFICATION_ENABLED="true" # Desktop notifications
BATCH_MODE="false"          # Skip all prompts for playlists
DUPLICATE_CHECK="true"      # Check for duplicates before downloading

# Metadata Settings
AUTO_TAG="true"             # Automatically tag MP3 files with metadata
FETCH_LYRICS="false"        # Download lyrics if available
FETCH_ALBUM_ART="true"      # Download album artwork

EOF
    echo -e "\033[0;32m[INFO]\033[0m Created default configuration file: $CONFIG_FILE"
}

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
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Global variables for statistics
TOTAL_DOWNLOADED=0
TOTAL_FAILED=0
TOTAL_SKIPPED=0
START_TIME=$(date +%s)

# Load configuration
load_config

# Initialize logs
> "$ERROR_LOG"
echo "=== Download Session Started: $(date) ===" >> "$HISTORY_FILE"

# Utility Functions
log_to_history() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$HISTORY_FILE"
}

validate_url() {
    local url="$1"
    if [[ "$url" =~ ^https?://(www\.)?(youtube|youtu\.be|soundcloud|bandcamp|vimeo) ]]; then
        return 0
    else
        return 1
    fi
}

send_notification() {
    if [[ "$NOTIFICATION_ENABLED" == "true" ]] && command -v notify-send >/dev/null 2>&1; then
        notify-send "YT-DLP Downloader" "$1"
    fi
}

get_video_info() {
    local url="$1"
    local info=$("$YTDLP_BIN" --dump-json --no-warnings "$url" 2>/dev/null | head -1)
    if [[ -n "$info" ]]; then
        echo "$info"
        return 0
    else
        return 1
    fi
}

calculate_eta() {
    local current=$1
    local total=$2
    local elapsed=$(($(date +%s) - START_TIME))
    
    if [[ $current -gt 0 ]]; then
        local rate=$((elapsed / current))
        local remaining=$((total - current))
        local eta=$((remaining * rate))
        
        local hours=$((eta / 3600))
        local minutes=$(((eta % 3600) / 60))
        local seconds=$((eta % 60))
        
        printf "%02d:%02d:%02d" $hours $minutes $seconds
    else
        echo "Calculating..."
    fi
}

# ASCII Art
echo "
 ♪♫♪ Enhanced YT-DLP Music Downloader v2.0 ♪♫♪
 /\_/\  
( o.o ) 
 > ^ <
"

# Welcome message
echo "======================================================================================================"
echo -e "${GREEN}Welcome to Enhanced YT-DLP Music Downloader!${NC}"
echo "Configuration loaded from: $CONFIG_FILE"
echo "Audio Format: $AUDIO_FORMAT | Quality: $AUDIO_QUALITY | Organization: $ORGANIZATION"
echo "Songs will be saved to your Music folder with $ORGANIZATION organization"
echo "======================================================================================================"

# Interactive configuration menu
show_config_menu() {
    echo -e "${CYAN}=== Configuration Menu ===${NC}"
    echo "1. Change audio format (current: $AUDIO_FORMAT)"
    echo "2. Change audio quality (current: $AUDIO_QUALITY)"
    echo "3. Change organization style (current: $ORGANIZATION)"
    echo "4. Change naming pattern (current: $NAMING_PATTERN)"
    echo "5. Toggle thumbnails (current: $DOWNLOAD_THUMBNAILS)"
    echo "6. Toggle subtitles (current: $DOWNLOAD_SUBTITLES)"
    echo "7. Set max retries (current: $MAX_RETRIES)"
    echo "8. Set parallel downloads (current: $PARALLEL_DOWNLOADS)"
    echo "9. Continue with current settings"
    echo ""
    read -p "Choose option (1-9): " config_choice
    
    case $config_choice in
        1)
            echo "Available formats: mp3, m4a, flac, opus, wav"
            read -p "Enter audio format: " AUDIO_FORMAT
            ;;
        2)
            echo "Quality options: 0 (best), 1-9 (worst), or bitrate like 320K"
            read -p "Enter audio quality: " AUDIO_QUALITY
            ;;
        3)
            echo "Organization options: monthly, artist, album, year, flat"
            read -p "Enter organization style: " ORGANIZATION
            ;;
        4)
            echo "Naming patterns: %(title)s, %(artist)s - %(title)s, %(album)s/%(title)s"
            read -p "Enter naming pattern: " NAMING_PATTERN
            ;;
        5)
            if [[ "$DOWNLOAD_THUMBNAILS" == "true" ]]; then
                DOWNLOAD_THUMBNAILS="false"
            else
                DOWNLOAD_THUMBNAILS="true"
            fi
            ;;
        6)
            if [[ "$DOWNLOAD_SUBTITLES" == "true" ]]; then
                DOWNLOAD_SUBTITLES="false"
            else
                DOWNLOAD_SUBTITLES="true"
            fi
            ;;
        7)
            read -p "Enter max retries (1-10): " MAX_RETRIES
            ;;
        8)
            read -p "Enter parallel downloads (1-5): " PARALLEL_DOWNLOADS
            ;;
        9)
            return
            ;;
    esac
    
    # Save updated config
    sed -i "s/AUDIO_FORMAT=.*/AUDIO_FORMAT=\"$AUDIO_FORMAT\"/" "$CONFIG_FILE"
    sed -i "s/AUDIO_QUALITY=.*/AUDIO_QUALITY=\"$AUDIO_QUALITY\"/" "$CONFIG_FILE"
    sed -i "s/ORGANIZATION=.*/ORGANIZATION=\"$ORGANIZATION\"/" "$CONFIG_FILE"
    sed -i "s/NAMING_PATTERN=.*/NAMING_PATTERN=\"$NAMING_PATTERN\"/" "$CONFIG_FILE"
    sed -i "s/DOWNLOAD_THUMBNAILS=.*/DOWNLOAD_THUMBNAILS=\"$DOWNLOAD_THUMBNAILS\"/" "$CONFIG_FILE"
    sed -i "s/DOWNLOAD_SUBTITLES=.*/DOWNLOAD_SUBTITLES=\"$DOWNLOAD_SUBTITLES\"/" "$CONFIG_FILE"
    sed -i "s/MAX_RETRIES=.*/MAX_RETRIES=\"$MAX_RETRIES\"/" "$CONFIG_FILE"
    sed -i "s/PARALLEL_DOWNLOADS=.*/PARALLEL_DOWNLOADS=\"$PARALLEL_DOWNLOADS\"/" "$CONFIG_FILE"
    
    echo -e "${GREEN}Configuration updated!${NC}"
    show_config_menu
}

# Ask if user wants to modify configuration
read -p "Do you want to modify configuration? [y/N]: " modify_config
if [[ "$modify_config" =~ ^[Yy]$ ]]; then
    show_config_menu
fi

# Create folders based on organization setting
create_download_folder() {
    local base_path="$HOME/Music"
    local folder_path=""
    
    case "$ORGANIZATION" in
        "monthly")
            local month_year=$(date +"%B-%Y")
            folder_path="$base_path/$month_year"
            ;;
        "artist")
            folder_path="$base_path/By Artist"
            ;;
        "album")
            folder_path="$base_path/By Album"
            ;;
        "year")
            local year=$(date +"%Y")
            folder_path="$base_path/$year"
            ;;
        "flat")
            folder_path="$base_path/Downloads"
            ;;
        *)
            folder_path="$base_path/$(date +"%B-%Y")"
            ;;
    esac
    
    if [[ ! -d "$folder_path" ]]; then
        mkdir -p "$folder_path"
        echo -e "${BLUE}Created folder: $folder_path${NC}" >&2
    fi
    
    echo "$folder_path"
}

get_organized_path() {
    local base_folder="$1"
    local video_info="$2"
    local url="$3"
    
    case "$ORGANIZATION" in
        "artist")
            local artist=$(echo "$video_info" | jq -r '.uploader // .artist // "Unknown Artist"' 2>/dev/null)
            if [[ "$artist" == "null" || -z "$artist" ]]; then
                artist="Unknown Artist"
            fi
            echo "$base_folder/$artist"
            ;;
        "album")
            local album=$(echo "$video_info" | jq -r '.album // .playlist_title // "Unknown Album"' 2>/dev/null)
            if [[ "$album" == "null" || -z "$album" ]]; then
                album="Unknown Album"
            fi
            echo "$base_folder/$album"
            ;;
        *)
            echo "$base_folder"
            ;;
    esac
}

# Enhanced progress bar with ETA and statistics
show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((current * width / total))
    local eta=$(calculate_eta "$current" "$total")
    
    printf "\r${BLUE}Progress: [${NC}"
    for ((i=0; i<completed; i++)); do printf "█"; done
    for ((i=completed; i<width; i++)); do printf "░"; done
    printf "${BLUE}] ${percentage}%% (${current}/${total}) ETA: ${eta}${NC}"
    
    if [[ $current -eq $total ]]; then
        echo ""
        show_final_statistics
    fi
}

show_final_statistics() {
    local total_time=$(($(date +%s) - START_TIME))
    local hours=$((total_time / 3600))
    local minutes=$(((total_time % 3600) / 60))
    local seconds=$((total_time % 60))
    
    echo ""
    echo -e "${CYAN}=== Download Statistics ===${NC}"
    echo -e "${GREEN}✓ Successfully downloaded: $TOTAL_DOWNLOADED${NC}"
    echo -e "${RED}✗ Failed downloads: $TOTAL_FAILED${NC}"
    echo -e "${YELLOW}⊘ Skipped (duplicates): $TOTAL_SKIPPED${NC}"
    printf "${BLUE}⏱ Total time: %02d:%02d:%02d${NC}\n" $hours $minutes $seconds
    echo ""
}

check_duplicate() {
    local title="$1"
    local format="$2"
    local search_path="$3"
    
    if [[ "$DUPLICATE_CHECK" == "true" ]]; then
        # Clean title for filename search
        local clean_title=$(echo "$title" | sed 's/[^a-zA-Z0-9 ._-]//g')
        
        # Search for existing files with similar names
        if find "$search_path" -type f -name "*$clean_title*.$format" 2>/dev/null | grep -q .; then
            return 0  # Duplicate found
        fi
    fi
    return 1  # No duplicate
}

retry_download() {
    local url="$1"
    local options=("${@:2}")
    local attempt=1
    
    while [[ $attempt -le $MAX_RETRIES ]]; do
        echo -e "${YELLOW}Attempt $attempt of $MAX_RETRIES...${NC}"
        
        if "$YTDLP_BIN" "${options[@]}" "$url"; then
            return 0  # Success
        fi
        
        ((attempt++))
        if [[ $attempt -le $MAX_RETRIES ]]; then
            echo -e "${YELLOW}Waiting 5 seconds before retry...${NC}"
            sleep 5
        fi
    done
    
    return 1  # Failed after all retries
}

# Enhanced download function with all new features
download_url() {
    local url="$1"
    local count="$2"
    local total="$3"
    local base_folder="$4"
    
    echo ""
    echo -e "${YELLOW}Processing Music $count: ${NC}"
    echo -e "${YELLOW}URL: $url${NC}"
    
    # Validate URL
    if ! validate_url "$url"; then
        echo -e "${RED}❌ Invalid URL: $url${NC}"
        echo "Invalid URL: $url" >> "$ERROR_LOG"
        log_to_history "FAILED: Invalid URL - $url"
        ((TOTAL_FAILED++))
        show_progress "$count" "$total"
        return
    fi
    
    # Get video information
    echo -e "${CYAN}📋 Fetching video information...${NC}"
    local video_info=$(get_video_info "$url")
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}❌ Failed to get video information${NC}"
        echo "Failed to get info: $url" >> "$ERROR_LOG"
        log_to_history "FAILED: No video info - $url"
        ((TOTAL_FAILED++))
        show_progress "$count" "$total"
        return
    fi
    
    # Extract video details
    local title=$(echo "$video_info" | jq -r '.title // "Unknown Title"' 2>/dev/null)
    local uploader=$(echo "$video_info" | jq -r '.uploader // "Unknown Artist"' 2>/dev/null)
    local duration=$(echo "$video_info" | jq -r '.duration // 0' 2>/dev/null)
    
    echo -e "${GREEN}🎵 Title: $title${NC}"
    echo -e "${GREEN}👤 Artist: $uploader${NC}"
    if [[ "$duration" != "0" && "$duration" != "null" ]]; then
        local mins=$((duration / 60))
        local secs=$((duration % 60))
        echo -e "${GREEN}⏱ Duration: ${mins}m ${secs}s${NC}"
    fi
    
    # Determine download folder based on organization
    local download_folder=$(get_organized_path "$base_folder" "$video_info" "$url")
    mkdir -p "$download_folder"
    
    # Check for duplicates
    if check_duplicate "$title" "$AUDIO_FORMAT" "$download_folder"; then
        echo -e "${YELLOW}⚠️ Duplicate found, skipping: $title${NC}"
        log_to_history "SKIPPED: Duplicate - $title"
        ((TOTAL_SKIPPED++))
        show_progress "$count" "$total"
        return
    fi
    
    # Prepare yt-dlp options
    local output_template="$download_folder/$NAMING_PATTERN.$AUDIO_FORMAT"
    local YTDLP_OPTS=(
        --extract-audio 
        --audio-format "$AUDIO_FORMAT" 
        --audio-quality "$AUDIO_QUALITY"
        --output "$output_template"
        --no-overwrites
        --ignore-errors
        --no-warnings
    )
    
    # Add optional features
    if [[ "$DOWNLOAD_THUMBNAILS" == "true" ]]; then
        YTDLP_OPTS+=(--write-thumbnail --embed-thumbnail)
    fi
    
    if [[ "$DOWNLOAD_SUBTITLES" == "true" ]]; then
        YTDLP_OPTS+=(--write-auto-sub --sub-lang en)
    fi
    
    if [[ -n "$PROXY_URL" ]]; then
        YTDLP_OPTS+=(--proxy "$PROXY_URL")
    fi
    
    if [[ -n "$MAX_SPEED" ]]; then
        YTDLP_OPTS+=(--limit-rate "$MAX_SPEED")
    fi
    
    # Handle playlists
    if [[ "$url" == *"list="* ]]; then
        echo -e "${PURPLE}🎵 Playlist detected!${NC}"
        if [[ "$BATCH_MODE" == "true" ]]; then
            choice="P"
        else
            echo "Do you want to download the whole playlist or just the single song?"
            echo "P = Playlist | S = Single song"
            while true; do
                read -p "Enter choice (P/S): " choice < /dev/tty
                choice=$(echo "$choice" | tr '[:lower:]' '[:upper:]')
                if [[ "$choice" == "P" || "$choice" == "S" ]]; then
                    break
                else
                    echo -e "${RED}❌ Invalid choice. Please enter P or S.${NC}"
                fi
            done
        fi
        
        if [[ "$choice" == "P" ]]; then
            echo -e "${GREEN}📦 Downloading whole playlist...${NC}"
            if retry_download "$url" "${YTDLP_OPTS[@]}"; then
                log_to_history "SUCCESS: Playlist - $title"
                ((TOTAL_DOWNLOADED++))
            else
                echo "Failed playlist: $url" >> "$ERROR_LOG"
                log_to_history "FAILED: Playlist - $title"
                ((TOTAL_FAILED++))
            fi
        elif [[ "$choice" == "S" ]]; then
            local cleaned_url=$(echo "$url" | sed 's/[&?]list=[^&]*//g')
            echo -e "${GREEN}🎵 Downloading single song...${NC}"
            if retry_download "$cleaned_url" "${YTDLP_OPTS[@]}"; then
                log_to_history "SUCCESS: Single from playlist - $title"
                ((TOTAL_DOWNLOADED++))
            else
                echo "Failed single: $cleaned_url" >> "$ERROR_LOG"
                log_to_history "FAILED: Single from playlist - $title"
                ((TOTAL_FAILED++))
            fi
        fi
    else
        # Regular single video URL
        echo -e "${GREEN}🎵 Downloading single song...${NC}"
        if retry_download "$url" "${YTDLP_OPTS[@]}"; then
            log_to_history "SUCCESS: Single - $title"
            ((TOTAL_DOWNLOADED++))
            
            # Post-processing: Add metadata tags
            if [[ "$AUTO_TAG" == "true" && "$AUDIO_FORMAT" == "mp3" ]]; then
                local downloaded_file="$download_folder/$title.$AUDIO_FORMAT"
                if [[ -f "$downloaded_file" ]] && command -v eyeD3 >/dev/null 2>&1; then
                    echo -e "${CYAN}🏷️ Adding metadata tags...${NC}"
                    eyeD3 --title="$title" --artist="$uploader" "$downloaded_file" >/dev/null 2>&1
                fi
            fi
        else
            echo "Failed: $url" >> "$ERROR_LOG"
            log_to_history "FAILED: Single - $title"
            ((TOTAL_FAILED++))
        fi
    fi
    
    show_progress "$count" "$total"
}

# Multiple input source support
get_urls_from_sources() {
    local urls=()
    
    # Primary source: music.txt
    if [[ -f "music.txt" ]]; then
        while IFS= read -r line; do
            if [[ -n "$line" && "$line" != "" && ! "$line" =~ ^[[:space:]]*# ]]; then
                urls+=("$line")
            fi
        done < music.txt
    fi
    
    # Secondary source: CSV file with metadata
    if [[ -f "music.csv" ]]; then
        echo -e "${CYAN}📄 Found music.csv with metadata${NC}"
        while IFS=, read -r url artist title album year; do
            if [[ -n "$url" && "$url" != "URL" ]]; then  # Skip header
                urls+=("$url")
            fi
        done < music.csv
    fi
    
    # Clipboard support (if xclip is available)
    if command -v xclip >/dev/null 2>&1; then
        read -p "Check clipboard for URLs? [y/N]: " check_clipboard
        if [[ "$check_clipboard" =~ ^[Yy]$ ]]; then
            local clipboard_content=$(xclip -selection clipboard -o 2>/dev/null)
            if validate_url "$clipboard_content"; then
                echo -e "${GREEN}📋 Valid URL found in clipboard${NC}"
                urls+=("$clipboard_content")
            fi
        fi
    fi
    
    printf '%s\n' "${urls[@]}"
}

# Check requirements and suggest installations
check_dependencies() {
    local missing_deps=()
    
    # Check for jq (JSON parsing)
    if ! command -v jq >/dev/null 2>&1; then
        missing_deps+=("jq")
    fi
    
    # Check for optional dependencies
    echo -e "${CYAN}=== Checking Optional Dependencies ===${NC}"
    
    if ! command -v eyeD3 >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️ eyeD3 not found (needed for MP3 metadata tagging)${NC}"
        echo "   Install with: pip install eyeD3"
    else
        echo -e "${GREEN}✓ eyeD3 found${NC}"
    fi
    
    if ! command -v notify-send >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️ notify-send not found (needed for notifications)${NC}"
        echo "   Install with: sudo apt install libnotify-bin"
    else
        echo -e "${GREEN}✓ notify-send found${NC}"
    fi
    
    if ! command -v xclip >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️ xclip not found (needed for clipboard support)${NC}"
        echo "   Install with: sudo apt install xclip"
    else
        echo -e "${GREEN}✓ xclip found${NC}"
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo -e "${RED}❌ Missing required dependencies: ${missing_deps[*]}${NC}"
        echo "Please install them and run the script again."
        exit 1
    fi
    
    echo ""
}

# Main execution starts here
check_dependencies

# Check for input files
if [[ ! -f "music.txt" && ! -f "music.csv" ]]; then
    echo -e "${RED}❌ Error: No input files found!${NC}"
    echo "Create music.txt with URLs (one per line) or music.csv with metadata"
    echo ""
    echo "Example music.txt:"
    echo "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
    echo "https://www.youtube.com/watch?v=oHg5SJYRHA0"
    echo ""
    echo "Example music.csv:"
    echo "URL,Artist,Title,Album,Year"
    echo "https://www.youtube.com/watch?v=dQw4w9WgXcQ,Rick Astley,Never Gonna Give You Up,Whenever You Need Somebody,1987"
    exit 1
fi

# Create download folder
base_folder=$(create_download_folder)

# Get URLs from all sources
mapfile -t all_urls < <(get_urls_from_sources)
total_urls=${#all_urls[@]}

if [[ $total_urls -eq 0 ]]; then
    echo -e "${RED}❌ No valid URLs found in any source files${NC}"
    exit 1
fi

echo -e "${BLUE}📊 Found $total_urls URLs to process${NC}"
echo -e "${BLUE}💾 Downloads will be saved to: $base_folder${NC}"
echo -e "${BLUE}🎯 Organization style: $ORGANIZATION${NC}"
echo ""

# Process all URLs
count=0
for music_link in "${all_urls[@]}"; do
    ((count++))
    download_url "$music_link" "$count" "$total_urls" "$base_folder"
    echo "----------------------------------------"
done

echo ""
echo -e "${GREEN}🎉 All downloads completed!${NC}"
echo -e "${GREEN}📁 Files saved in: $base_folder${NC}"

# Send completion notification
send_notification "All downloads completed! Downloaded: $TOTAL_DOWNLOADED, Failed: $TOTAL_FAILED, Skipped: $TOTAL_SKIPPED"

# Show final summary
if [[ $TOTAL_FAILED -gt 0 ]]; then
    echo -e "${RED}Some downloads failed. Check $ERROR_LOG for details.${NC}"
fi

echo -e "${CYAN}Full download history available in: $HISTORY_FILE${NC}"
