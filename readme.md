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

-   **`bash`**: The script is designed to run in a Bash environment (standard on most Linux distributions and macOS).
-   **`wget`**: Used for auto-downloading yt-dlp if not present. (Pre-installed on most Linux/macOS, or install via `brew install wget` on macOS.)

**No need to manually install `yt-dlp`!**

If `yt-dlp` is not found, the script will automatically download the latest version and use it locally. If you want to install it system-wide, you still can:

```bash
# Using pip (optional)
pip install -U yt-dlp
```


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

## 🖥️ Platform Support

- **Linux**: Fully supported.
- **macOS**: Fully supported. (If you get a permissions error on the downloaded yt-dlp, run `chmod +x yt-dlp`.)
- **Android (Termux)**: Supported. See below.
- **Windows**: Not officially supported, but you can try using WSL or Git Bash.

---

## Contributing

Contributions are welcome! If you have ideas for improvements or find a bug, feel free to open an issue or submit a pull request. 
This is a simple project i made for automating downloading song etc from different sources:
  It based on [yt-dlp](https://github.com/yt-dlp/yt-dlp)

# Added file support
      Just put your all link in music.txt line by line and excute the music.sh and follow the simple instruction

## 📱 Android (Termux)

1. Install [Termux](https://f-droid.org/packages/com.termux/) from F-Droid or GitHub.
2. Install `wget` and `bash` if not present:
    ```bash
    pkg install wget bash
    ```
3. Clone the repo and run the script as above.

## 🪟 Windows

Not officially supported, but you can try using [WSL](https://docs.microsoft.com/en-us/windows/wsl/) or [Git Bash](https://gitforwindows.org/).
