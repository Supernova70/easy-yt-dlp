# 🎵 Enhanced Easy YT-DLP Music Downloader v2.0

A powerful, feature-rich command-line tool for downloading music from YouTube and other platforms. This enhanced version includes advanced organization, configuration management, multiple input sources, smart features, and comprehensive error handling.

## ✨ Features Overview

### 🎯 **Core Features**
- **Multiple Input Sources**: Support for `music.txt`, `music.csv`, and clipboard URLs
- **Smart Configuration**: Persistent configuration file with interactive menu
- **Advanced Organization**: Multiple folder organization styles (monthly, artist, album, year, flat)
- **Quality Control**: Choose audio format (mp3, m4a, flac, opus, wav) and quality levels
- **Intelligent Duplicate Detection**: Skips already downloaded files across all folders
- **Robust Error Handling**: Automatic retries with detailed error logging

### 🎨 **Advanced Features**
- **Metadata Support**: CSV input with artist, title, album, and year information
- **Auto-Tagging**: Automatic MP3 metadata tagging with eyeD3
- **Thumbnail & Subtitle Support**: Optional thumbnail embedding and subtitle downloading
- **Progress Tracking**: Enhanced progress bar with ETA and real-time statistics
- **Download History**: Complete logging of all download sessions
- **Desktop Notifications**: System notifications for download completion
- **Playlist Intelligence**: Smart playlist detection with user choice options

### ⚙️ **Technical Features**
- **Parallel Downloads**: Configure multiple simultaneous downloads (1-5)
- **Speed Limiting**: Set maximum download speed
- **Proxy Support**: Built-in proxy configuration
- **Resume Capability**: Automatic resume for interrupted downloads
- **Batch Mode**: Unattended operation for playlists
- **URL Validation**: Smart validation for supported platforms
- **Dependency Checking**: Automatic detection of optional dependencies

## 📋 Requirements

### Required
- **bash** (4.0+)
- **yt-dlp** (auto-downloaded if not found)
- **jq** (for JSON parsing)
  ```bash
  # Ubuntu/Debian
  sudo apt install jq
  
  # macOS
  brew install jq
  ```

### Optional (for enhanced features)
- **eyeD3** (MP3 metadata tagging)
  ```bash
  pip install eyeD3
  ```
- **notify-send** (desktop notifications)
  ```bash
  sudo apt install libnotify-bin
  ```
- **xclip** (clipboard support)
  ```bash
  sudo apt install xclip
  ```

## 🚀 Quick Start

1. **Clone and setup**:
   ```bash
   git clone https://github.com/Supernova70/easy-yt-dlp.git
   cd easy-yt-dlp
   chmod +x music.sh
   ```

2. **Add your URLs** to `music.txt`:
   ```
   https://www.youtube.com/watch?v=dQw4w9WgXcQ
   https://www.youtube.com/watch?v=oHg5SJYRHA0
   # This is a comment - will be ignored
   ```

3. **Run the script**:
   ```bash
   ./music.sh
   ```

## 📁 Input Formats

### Method 1: Simple URL List (`music.txt`)
```
https://www.youtube.com/watch?v=dQw4w9WgXcQ
https://www.youtube.com/watch?v=oHg5SJYRHA0
https://soundcloud.com/example/track
# Comments start with # and are ignored
```

### Method 2: CSV with Metadata (`music.csv`)
```csv
URL,Artist,Title,Album,Year
https://www.youtube.com/watch?v=dQw4w9WgXcQ,Rick Astley,Never Gonna Give You Up,Whenever You Need Somebody,1987
https://www.youtube.com/watch?v=oHg5SJYRHA0,Rick Astley,Never Gonna Let You Down,Whenever You Need Somebody,1987
```

### Method 3: Clipboard Integration
The script can detect and use URLs from your system clipboard (requires `xclip`).

## ⚙️ Configuration

### Interactive Configuration Menu
On first run or when requested, you'll see a configuration menu:

```
=== Configuration Menu ===
1. Change audio format (current: mp3)
2. Change audio quality (current: 0)
3. Change organization style (current: monthly)
4. Change naming pattern (current: %(artist)s - %(title)s)
5. Toggle thumbnails (current: false)
6. Toggle subtitles (current: false)
7. Set max retries (current: 3)
8. Set parallel downloads (current: 1)
9. Continue with current settings
```

### Configuration File (`config.ini`)
```ini
# Audio Settings
AUDIO_FORMAT="mp3"          # mp3, m4a, flac, opus, wav
AUDIO_QUALITY="0"           # 0 (best), 1-9 (worst), or bitrate like 320K
VIDEO_FORMAT="mp4"          # mp4, webm, mkv, avi

# Organization Settings  
ORGANIZATION="monthly"      # monthly, artist, album, year, flat
NAMING_PATTERN="%(artist)s - %(title)s"  # Filename pattern
DOWNLOAD_THUMBNAILS="false" # Embed thumbnails
DOWNLOAD_SUBTITLES="false"  # Download subtitles

# Performance Settings
MAX_RETRIES="3"             # Retry attempts for failed downloads
PARALLEL_DOWNLOADS="1"      # Simultaneous downloads (1-5)
MAX_SPEED=""                # Download speed limit (e.g., 1M, 500K)

# Advanced Settings
PROXY_URL=""                # Proxy configuration
BACKUP_ENABLED="false"      # Cloud backup (future feature)
NOTIFICATION_ENABLED="true" # Desktop notifications
BATCH_MODE="false"          # Auto-handle playlists
DUPLICATE_CHECK="true"      # Skip existing files

# Metadata Settings
AUTO_TAG="true"             # Auto-tag MP3 files
FETCH_LYRICS="false"        # Download lyrics (future feature)
FETCH_ALBUM_ART="true"      # Download album art
```

## 📂 Organization Styles

### 1. Monthly Organization (`monthly`)
```
~/Music/
├── August-2025/
│   ├── Song1.mp3
│   ├── Song2.mp3
└── September-2025/
    ├── Song3.mp3
```

### 2. Artist Organization (`artist`)
```
~/Music/By Artist/
├── Rick Astley/
│   ├── Never Gonna Give You Up.mp3
│   └── Never Gonna Let You Down.mp3
├── Queen/
│   ├── Bohemian Rhapsody.mp3
```

### 3. Album Organization (`album`)
```
~/Music/By Album/
├── Whenever You Need Somebody/
│   ├── Never Gonna Give You Up.mp3
│   └── Never Gonna Let You Down.mp3
├── A Night at the Opera/
│   ├── Bohemian Rhapsody.mp3
```

### 4. Year Organization (`year`)
```
~/Music/
├── 2025/
│   ├── Latest Song.mp3
├── 1987/
│   ├── Never Gonna Give You Up.mp3
```

### 5. Flat Organization (`flat`)
```
~/Music/Downloads/
├── Song1.mp3
├── Song2.mp3
├── Song3.mp3
```

## 🔧 Advanced Usage

### Custom Naming Patterns
- `%(title)s` - Song title only
- `%(artist)s - %(title)s` - Artist and title
- `%(album)s/%(title)s` - Album folder with title
- `%(upload_date)s - %(title)s` - Date and title

### Quality Settings
- **0** - Best available quality
- **1-9** - Decreasing quality levels
- **320K** - Specific bitrate (320 kbps)
- **192K** - Lower bitrate (192 kbps)

### Parallel Downloads
Configure simultaneous downloads (1-5) for faster processing of large lists:
```ini
PARALLEL_DOWNLOADS="3"  # Download 3 songs simultaneously
```

### Speed Limiting
Set maximum download speed to avoid bandwidth issues:
```ini
MAX_SPEED="1M"    # Limit to 1 MB/s
MAX_SPEED="500K"  # Limit to 500 KB/s
```

## 📊 Monitoring & Logging

### Real-time Progress
```
Progress: [████████████████████████████████████████] 85% (17/20) ETA: 00:02:30
```

### Download Statistics
```
=== Download Statistics ===
✓ Successfully downloaded: 18
✗ Failed downloads: 1
⊘ Skipped (duplicates): 1
⏱ Total time: 00:15:42
```

### Log Files
- **`download_history.log`** - Complete session history
- **`error.log`** - Failed downloads and errors
- **`config.ini`** - User configuration

## 🎵 Supported Platforms

- **YouTube** (videos, playlists, channels)
- **SoundCloud** (tracks, playlists)
- **Bandcamp** (albums, tracks)
- **Vimeo** (videos)
- **And many more** (via yt-dlp support)

## 🔧 Troubleshooting

### Common Issues

1. **"No valid URLs found"**
   ```bash
   # Check file encoding and line endings
   file music.txt
   dos2unix music.txt  # Convert Windows line endings
   ```

2. **"Permission denied"**
   ```bash
   chmod +x music.sh
   ```

3. **Missing dependencies**
   ```bash
   # Install required packages
   sudo apt update
   sudo apt install jq curl wget
   ```

4. **yt-dlp outdated**
   ```bash
   # Update yt-dlp
   pip install --upgrade yt-dlp
   # Or let the script auto-download latest version
   ```

### Debug Mode
Add debug output by modifying the script:
```bash
set -x  # Add this line at the top for debug mode
```

### Network Issues
Configure proxy if needed:
```ini
PROXY_URL="http://proxy.example.com:8080"
```

## 📈 Performance Tips

1. **Use parallel downloads** for large lists (set `PARALLEL_DOWNLOADS="3"`)
2. **Enable duplicate checking** to avoid re-downloading
3. **Set appropriate quality** (320K for good balance of quality/size)
4. **Use batch mode** for unattended playlist downloads
5. **Limit download speed** if you need bandwidth for other tasks

## 🔮 Future Features (Roadmap)

- **Cloud Storage Integration** (Google Drive, Dropbox)
- **Spotify/Apple Music Playlist Import**
- **Lyrics Fetching** and embedding
- **Music Database Integration** (MusicBrainz)
- **Web Interface** for remote management
- **Mobile App** companion
- **AI-powered** music discovery

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Commit changes: `git commit -am 'Add feature'`
4. Push to branch: `git push origin feature-name`
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **yt-dlp** team for the excellent downloading library
- **Contributors** who suggest features and report issues
- **Open source community** for tools and inspiration

---

**Happy Downloading! 🎵**

For issues, feature requests, or questions, please visit our [GitHub Issues](https://github.com/Supernova70/easy-yt-dlp/issues) page.
