# Changelog

All notable changes to this project will be documented in this file.

## [2.0.0] - 2025-08-16

### Added
- **Configuration Management**: Persistent configuration file with interactive menu
- **Multiple Input Sources**: Support for music.txt, music.csv, and clipboard URLs
- **Advanced Organization**: 5 different folder organization styles (monthly, artist, album, year, flat)
- **Quality Control**: Multiple audio formats (mp3, m4a, flac, opus, wav) and quality levels
- **Intelligent Duplicate Detection**: Cross-folder duplicate checking
- **Robust Error Handling**: Automatic retries with configurable retry count
- **Metadata Support**: CSV input with artist, title, album, year information
- **Auto-Tagging**: Automatic MP3 metadata tagging with eyeD3
- **Thumbnail & Subtitle Support**: Optional embedding and downloading
- **Enhanced Progress Tracking**: ETA calculation and real-time statistics
- **Download History**: Complete session logging
- **Desktop Notifications**: System notifications for completion
- **Parallel Downloads**: Configurable simultaneous downloads (1-5)
- **Speed Limiting**: Configurable maximum download speed
- **Proxy Support**: Built-in proxy configuration
- **Resume Capability**: Automatic resume for interrupted downloads
- **Batch Mode**: Unattended operation for playlists
- **Smart URL Validation**: Support for multiple platforms
- **Dependency Checking**: Automatic detection of optional dependencies
- **Custom Naming Patterns**: Flexible file naming with metadata
- **Performance Statistics**: Detailed download analytics

### Enhanced
- **User Interface**: Colorful, informative output with emojis
- **Error Reporting**: Detailed error logging and categorization
- **Documentation**: Comprehensive README with examples and troubleshooting

### Changed
- **Architecture**: Complete rewrite for modularity and extensibility
- **Configuration**: File-based configuration instead of command-line prompts

## [1.0.0] - 2025-08-15

### Added
- Basic YouTube music downloading
- Simple progress bar
- Playlist detection and handling
- Monthly folder organization
- Auto-detection and download of yt-dlp

### Features
- Download music from YouTube URLs in music.txt
- Automatic organization into monthly folders
- Interactive playlist handling
- Basic progress tracking
- Simple error handling
