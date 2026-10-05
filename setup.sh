#!/usr/bin/env bash

# Exit immediately on unhandled fatal error
set -e

# Close active preference windows to prevent write collisions
osascript -e 'tell application "System Settings" to quit' 2>/dev/null || true
osascript -e 'tell application "System Preferences" to quit' 2>/dev/null || true

# -----------------------------------------------------------------------------
# Interactive Prompt Helper
# Directs input from /dev/tty to ensure compatibility with piped curl execution
# -----------------------------------------------------------------------------
ask_step() {
    local title="$1"
    local description="$2"
    local action="$3"

    echo ""
    echo "===================================================================="
    echo "  $title"
    echo "===================================================================="
    echo -e "Effect: $description"
    echo "--------------------------------------------------------------------"
    read -r -p "Apply this setting? [y/N]: " response < /dev/tty

    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        eval "$action"
        echo "--> Status: Applied."
    else
        echo "--> Status: Skipped."
    fi
}

echo "===================================================================="
echo "         macOS Developer Environment Configuration Assistant        "
echo "===================================================================="
echo "Every optimization explains its operational effect before execution."

# -----------------------------------------------------------------------------
# 1. Dock & Desktop
# -----------------------------------------------------------------------------
ask_step \
    "Dock: Instant Auto-Hide & Compact Layout" \
    "Removes Dock reveal delay, cuts animation duration to 0.15s, sets tile\n        size to 48px, hides recent apps, and prevents auto-reordering of spaces." \
    "defaults write com.apple.dock autohide -bool true && \
     defaults write com.apple.dock autohide-delay -float 0 && \
     defaults write com.apple.dock autohide-time-modifier -float 0.15 && \
     defaults write com.apple.dock tilesize -int 48 && \
     defaults write com.apple.dock show-recents -bool false && \
     defaults write com.apple.dock mru-spaces -bool false && \
     killall Dock 2>/dev/null || true"

# -----------------------------------------------------------------------------
# 2. Mouse & Trackpad Scaling
# -----------------------------------------------------------------------------
ask_step \
    "Mouse & Trackpad: Accelerated Cursor Tracking" \
    "Raises mouse tracking speed to 3.0 and trackpad tracking speed to 2.5,\n        exceeding default UI maximums for faster multi-monitor cursor travel." \
    "defaults write -g com.apple.mouse.scaling -float 3.0 && \
     defaults write -g com.apple.trackpad.scaling -float 2.5"

# -----------------------------------------------------------------------------
# 3. Keyboard & Text Editing
# -----------------------------------------------------------------------------
ask_step \
    "Keyboard: Rapid Key Repeat & Typing Corrections Bypass" \
    "Reduces key repeat initial delay to 12ms and repeats every 1ms for rapid\n        Vim/code navigation. Disables smart quotes, auto-capitalization, and\n        automatic period substitution to protect raw code snippets from formatting errors." \
    "defaults write -g KeyRepeat -int 1 && \
     defaults write -g InitialKeyRepeat -int 12 && \
     defaults write -g AppleKeyboardUIMode -int 2 && \
     defaults write -g NSAutomaticCapitalizationEnabled -bool false && \
     defaults write -g NSAutomaticDashSubstitutionEnabled -bool false && \
     defaults write -g NSAutomaticPeriodSubstitutionEnabled -bool false && \
     defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false && \
     defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false"

# -----------------------------------------------------------------------------
# 4. Display & Resolution
# -----------------------------------------------------------------------------
ask_step \
    "Display: Enable Native HiDPI Modes & Subpixel Font Smoothing" \
    "Enables macOS HiDPI scaling resolutions on external 2K/4K displays and restores\n        optimal subpixel font rendering for non-Retina monitors." \
    "sudo defaults write /Library/Preferences/com.apple.windowserver.plist DisplayResolutionEnabled -bool true && \
     defaults write -g CGFontRenderingFontSmoothingDisabled -bool false && \
     defaults write -g AppleFontSmoothing -int 1"

ask_step \
    "Display: Install 'displayplacer' CLI Utility" \
    "Installs displayplacer via Homebrew to query display IDs, set precise screen\n        resolutions, configure refresh rates (e.g., 120Hz/144Hz), and manage rotation via terminal." \
    "if command -v brew &>/dev/null; then \
        brew install displayplacer && echo 'Run \"displayplacer list\" in terminal to inspect displays.'; \
     else \
        echo 'Homebrew is required. Homebrew must be installed first to run \"brew install displayplacer\".'; \
     fi"

# -----------------------------------------------------------------------------
# 5. Finder & File System
# -----------------------------------------------------------------------------
ask_step \
    "Finder: Comprehensive Developer View" \
    "Forces hidden files (.env, .gitignore) to show, always displays file extensions,\n        enables the full folder path and status bars, defaults to list view ('Nlsv'),\n        and stops creation of .DS_Store files on network shares and USB volumes." \
    "defaults write com.apple.finder AppleShowAllFiles -bool true && \
     defaults write -g AppleShowAllExtensions -bool true && \
     defaults write com.apple.finder ShowPathbar -bool true && \
     defaults write com.apple.finder ShowStatusBar -bool true && \
     defaults write com.apple.finder FXPreferredViewStyle -string 'Nlsv' && \
     defaults write com.apple.finder FXDefaultSearchScope -string 'SCcf' && \
     defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true && \
     defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true && \
     killall Finder 2>/dev/null || true"

# -----------------------------------------------------------------------------
# 6. Directory Structure
# -----------------------------------------------------------------------------
ask_step \
    "Filesystem: Organized Developer Directory Tree" \
    "Creates a standard project hierarchy within the home directory:\n        ~/Developer/personal\n        ~/Developer/work\n        ~/Developer/sandbox\n        ~/Developer/bin" \
    "mkdir -p \"$HOME/Developer/personal\" \
              \"$HOME/Developer/work\" \
              \"$HOME/Developer/sandbox\" \
              \"$HOME/Developer/bin\""

# -----------------------------------------------------------------------------
# 7. Package Managers & Developer Tooling
# -----------------------------------------------------------------------------
if ! xcode-select -p &>/dev/null; then
    ask_step \
        "Tooling: Apple Command Line Developer Tools" \
        "Installs Apple's CLI toolchain including git, make, clang, and gcc." \
        "xcode-select --install"
else
    echo ""
    echo "✔ Apple Command Line Tools already detected."
fi

if ! command -v brew &>/dev/null; then
    ask_step \
        "Tooling: Homebrew Package Manager" \
        "Installs Homebrew for package and cask management from https://brew.sh." \
        "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
else
    echo ""
    echo "✔ Homebrew package manager already detected."
fi

# -----------------------------------------------------------------------------
# 8. Screenshots
# -----------------------------------------------------------------------------
ask_step \
    "Screenshots: Dedicated Folder & No Shadows" \
    "Changes default save location to ~/Pictures/Screenshots and removes\n        the drop-shadow effect from window screenshots for clean documentation." \
    "mkdir -p \"$HOME/Pictures/Screenshots\" && \
     defaults write com.apple.screencapture location -string \"$HOME/Pictures/Screenshots\" && \
     defaults write com.apple.screencapture disable-shadow -bool true && \
     killall SystemUIServer 2>/dev/null || true"

# -----------------------------------------------------------------------------
# 9. Safari Developer Tools
# -----------------------------------------------------------------------------
ask_step \
    "Safari: Enable Develop Menu & Web Inspector" \
    "Reveals the hidden Develop menu in Safari's menu bar and enables the\n        Web Inspector for debugging cross-browser web content natively." \
    "defaults write com.apple.Safari IncludeDevelopMenu -bool true && \
     defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true && \
     defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true && \
     defaults write -g WebKitDeveloperExtras -bool true"

# -----------------------------------------------------------------------------
# 10. Activity Monitor
# -----------------------------------------------------------------------------
ask_step \
    "Activity Monitor: Advanced Diagnostics" \
    "Accelerates the update frequency to 1 second and configures the monitor\n        to show all system processes rather than just user-level processes." \
    "defaults write com.apple.ActivityMonitor UpdatePeriod -int 1 && \
     defaults write com.apple.ActivityMonitor ShowCategory -int 0"

# -----------------------------------------------------------------------------
# 11. TextEdit
# -----------------------------------------------------------------------------
ask_step \
    "TextEdit: Default to Plain Text" \
    "Forces the native TextEdit application to use plain text (UTF-8) by\n        default instead of Rich Text (RTF), preventing accidental formatting of config files." \
    "defaults write com.apple.TextEdit RichText -int 0"

# -----------------------------------------------------------------------------
# 12. Crash Reporter
# -----------------------------------------------------------------------------
ask_step \
    "System: Disable Crash Reporter Dialogs" \
    "Disables the disruptive 'Application Quit Unexpectedly' modal dialogs.\n        Crashes are still logged silently to Console.app for debugging." \
    "defaults write com.apple.CrashReporter DialogType -string \"none\""

# -----------------------------------------------------------------------------
# 13. System Audio
# -----------------------------------------------------------------------------
ask_step \
    "Audio: Silence UI Interface Sounds" \
    "Disables macOS interface sound effects (e.g., volume pop, trash empty)." \
    "defaults write com.apple.systemsound com.apple.sound.uiaudio.enabled -int 0"

# -----------------------------------------------------------------------------
# 14. Security & Lock
# -----------------------------------------------------------------------------
ask_step \
    "Security: Instant Password Prompt" \
    "Configures the system to require a password immediately after the\n        display enters sleep mode or the screen saver starts." \
    "defaults write com.apple.screensaver askForPassword -int 1 && \
     defaults write com.apple.screensaver askForPasswordDelay -int 0"

# -----------------------------------------------------------------------------
# 15. Energy & Sleep
# -----------------------------------------------------------------------------
ask_step \
    "Energy: Prevent Sleep on Power" \
    "Prevents the machine from going to sleep automatically when connected\n        to an external power source. (Will prompt for admin password)." \
    "sudo pmset -c sleep 0"

echo ""
echo "===================================================================="
echo "                     Setup Procedure Finished                       "
echo "===================================================================="
echo "Restarting the Mac or logging out may be required for key repeat and"
echo "cursor sensitivity changes to take full effect across all processes."
