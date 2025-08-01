@echo off
setlocal enabledelayedexpansion

REM Set up colors
set "GREEN="
set "YELLOW="
set "RED="
set "NC="

REM Get current month and year
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (
    set "month=%%a"
    set "year=%%c"
)
REM Convert month number to name
set "monthName="
for %%m in (01 January 02 February 03 March 04 April 05 May 06 June 07 July 08 August 09 September 10 October 11 November 12 December) do (
    if "!month!"=="%%m" (
        set "monthName=%%n"
    )
    set "n=%%m"
)
if not defined monthName set "monthName=%month%"

set "musicFolder=%USERPROFILE%\Music\%monthName%-%year%"
if not exist "%musicFolder%" (
    mkdir "%musicFolder%"
    echo Created folder: "%musicFolder%"
)

REM Check for yt-dlp.exe
if not exist yt-dlp.exe (
    echo yt-dlp.exe not found, downloading...
    powershell -Command "Invoke-WebRequest -Uri https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe -OutFile yt-dlp.exe"
    if errorlevel 1 (
        echo Failed to download yt-dlp.exe. Please download it manually.
        exit /b 1
    )
)

REM Process music.txt
if not exist music.txt (
    echo music.txt not found!
    exit /b 1
)

set /a count=0
for /f "usebackq tokens=* delims=" %%L in ("music.txt") do (
    set "line=%%L"
    REM Skip empty lines and comments
    if not "!line!"=="" if not "!line:~0,1!"=="#" (
        set /a count+=1
        echo.
        echo Processing Music !count!: !line!
        echo !line! | findstr /i "list=" >nul
        if !errorlevel! == 0 (
            set /p choice=Playlist detected! Download whole playlist (P) or single song (S)? [P/S]: 
            set "choice=!choice:~0,1!"
            if /i "!choice!"=="P" (
                yt-dlp.exe --extract-audio --audio-format mp3 --audio-quality 0 --output "%musicFolder%\%%(title)s.%%(ext)s" "!line!"
            ) else if /i "!choice!"=="S" (
                REM Remove &list=... from the URL
                set "cleaned=!line:&list=!"
                yt-dlp.exe --extract-audio --audio-format mp3 --audio-quality 0 --output "%musicFolder%\%%(title)s.%%(ext)s" "!cleaned!"
            ) else (
                echo Invalid choice. Skipping this URL.
            )
        ) else (
            yt-dlp.exe --extract-audio --audio-format mp3 --audio-quality 0 --output "%musicFolder%\%%(title)s.%%(ext)s" "!line!"
        )
    )
)

echo.
echo All downloads completed!
echo Files saved in: "%musicFolder%"
pause