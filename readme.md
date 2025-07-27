	 # Easy YT-DLP: Your Automated Music Downloader

A smart and simple command-line tool to automate downloading your favorite music from YouTube. This script reads a list of URLs from a `music.txt` file, downloads them in the best audio quality, and organizes them neatly into monthly folders in your main Music directory.

---

## ✨ Key Features

-   **🎵 Bulk Downloads**: Just drop your YouTube links into `music.txt` and let the script do the rest.
-   **🤖 Smart Playlist Handling**: Automatically detects playlists and asks if you want to download the entire playlist or just the single video.
-   **📁 Automatic Organization**: Sorts all your downloaded music into monthly folders inside your main `~/Music` directory (e.g., `~/Music/July-2025`).
-   **📊 Progress Bar**: A clean, visual progress bar shows you the status of your downloads.
-   **🎧 High-Quality Audio**: Downloads audio in MP3 format with the best available quality.
-   **⚙️ User-Friendly**: Simple to set up and run, with clear, colored output and interactive prompts.

---

## 🚀 Getting Started

### Prerequisites

Before you begin, make sure you have the following installed:

-   **`yt-dlp`**: The core dependency for downloading videos. You can install it via pip or your system's package manager.
    ```bash
    # Using pip (recommended)
    pip install -U yt-dlp
    ```
-   **`bash`**: The script is designed to run in a Bash environment (standard on most Linux distributions and macOS).

### Installation & Usage

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/Supernova70/easy-yt-dlp.git
    cd easy-yt-dlp
    ```

2.  **Create your music list:**
    Create a file named `music.txt` in the same directory. Add your YouTube URLs to this file, one link per line. You can also add comments by starting a line with `#`.

    **Example `music.txt`:**
    ```
    # My Favorite Songs
    https://www.youtube.com/watch?v=pG78z9PFGaw
    http://youtube.com/watch?v=tNc2coVC2aw

    # A playlist link
    https://www.youtube.com/watch?v=tG4Rq192WW0&list=PLPq6buArjiP4dw60xBU1R3u9WUd0COfHF
    ```

3.  **Make the script executable:**
    You only need to do this once.
    ```bash
    chmod +x music.sh
    ```

4.  **Run the script:**
    ```bash
    ./music.sh
    ```

The script will then process each link, download the audio, and save it to the appropriate monthly folder in your `~/Music` directory.

---

## Contributing

Contributions are welcome! If you have ideas for improvements or find a bug, feel free to open an issue or submit a pull request. 
This is a simple project i made for automating downloading song etc from different sources:
  It based on [yt-dlp](https://github.com/yt-dlp/yt-dlp)

# Added file support
      Just put your all link in music.txt line by line and excute the music.sh and follow the simple instruction
# Installation
  1. **Linux**
        - First download the yt-dlp 
		- Clone the repo and cd , make it excutable  
        - `git clone https://github.com/SuperNova70/easy-yt-dlp`
        - `cd easy_yt-dlp`
        - `chmod +x music.sh`
        - `./music.sh`
  2. **Android**
        - Install termux from the github 
        - follow this [link](https://gist.github.com/cyrillkuettel/d63785cf5f4c00106ae215188c377515)  to install termux and yt-dlp
        - go to directory like music of such
        - `git clone https://github.com/SuperNova70/easy-yt-dlp`
        - `cd easy_yt-dlp`
        - `chmod +x music.sh`
        - `./music.sh`
  3. Windows 
        - updating soon    
