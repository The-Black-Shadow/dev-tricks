#!/bin/bash

# ============================================
# Flutter/Xcode External Storage Setup
# Double-click runnable macOS script (.command)
# ============================================

clear

# ---------- Colors ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ---------- Header ----------

echo -e "${BLUE}"
echo "=============================================="
echo " Flutter Dev External Storage Setup"
echo "=============================================="
echo -e "${NC}"

# ---------- Prevent Running While IDEs Open ----------

# Android Studio detection uses -f for reliability
if pgrep -x "Xcode" >/dev/null || \
   pgrep -f "Android Studio.app" >/dev/null || \
   pgrep -x "Simulator" >/dev/null; then

    echo -e "${RED}Please close Xcode, Android Studio, and Simulator first.${NC}"
    echo ""
    read -p "Press ENTER to close..."
    exit 1
fi

# ---------- Check External Drives ----------

DRIVE_COUNT=$(ls /Volumes | grep -v "Macintosh HD" | wc -l)

if [[ "$DRIVE_COUNT" -eq 0 ]]; then
    echo -e "${RED}No external drives detected.${NC}"
    echo ""
    read -p "Press ENTER to close..."
    exit 1
fi

# ---------- Drive Picker ----------

DRIVE_NAME=$(osascript <<EOF
set driveList to paragraphs of (do shell script "ls /Volumes | grep -v 'Macintosh HD'")

set selectedDrive to choose from list driveList with prompt "Select your external drive:" without multiple selections allowed

if selectedDrive is false then
    return ""
else
    return item 1 of selectedDrive
end if
EOF
)

if [[ -z "$DRIVE_NAME" ]]; then
    echo -e "${RED}No drive selected. Exiting.${NC}"
    echo ""
    read -p "Press ENTER to close..."
    exit 1
fi

EXTERNAL_BASE="/Volumes/${DRIVE_NAME}/Developer"

echo -e "${GREEN}Selected Drive:${NC} $DRIVE_NAME"
echo ""

# ---------- Verify APFS ----------

FILESYSTEM=$(diskutil info "/Volumes/${DRIVE_NAME}" | awk -F': ' '/File System Personality/ {print $2}')

if [[ "$FILESYSTEM" != *"APFS"* && "$FILESYSTEM" != *"apfs"* ]]; then
    echo -e "${YELLOW}WARNING:${NC} Drive is not APFS formatted."
    echo "Current filesystem: $FILESYSTEM"
    echo ""
    echo "Xcode and Android development work best on APFS."
    echo ""
fi

# ---------- Check Free Space ----------

AVAILABLE=$(df -g "/Volumes/${DRIVE_NAME}" | awk 'NR==2 {print $4}')

if [[ "$AVAILABLE" -lt 20 ]]; then
    echo -e "${YELLOW}WARNING:${NC} Less than 20GB free on external drive."
    echo "Android SDKs and emulators can require significant space."
    echo ""
fi

# ---------- Warning Dialog ----------

if ! osascript <<EOF
display dialog "This script will move:

• Xcode DerivedData
• Xcode Archives
• Android SDK
• Gradle cache
• Android emulators

to:
$EXTERNAL_BASE

IMPORTANT:
Always connect the drive before opening:
• Xcode
• Android Studio
• Flutter
• Simulators" buttons {"Cancel", "Continue"} default button "Continue" cancel button "Cancel"
EOF
then
    echo -e "${RED}Setup cancelled by user.${NC}"
    echo ""
    read -p "Press ENTER to close..."
    exit 1
fi

# ---------- Create Folders ----------

echo -e "${BLUE}Creating external folders...${NC}"

mkdir -p "$EXTERNAL_BASE/Xcode"
mkdir -p "$EXTERNAL_BASE/Android"

# ---------- Helper Function ----------

move_and_link() {

    SRC="$1"
    DEST_PARENT="$2"

    NAME=$(basename "$SRC")
    DEST="$DEST_PARENT/$NAME"

    echo ""
    echo -e "${YELLOW}Processing:${NC} $NAME"

    # Remove broken symlink
    if [[ -L "$SRC" && ! -e "$SRC" ]]; then
        echo "Removing broken symlink..."
        rm "$SRC"
    fi

    # Already symlinked and valid
    if [[ -L "$SRC" && -e "$SRC" ]]; then
        echo -e "${GREEN}Already symlinked. Skipping.${NC}"
        return
    fi

    # Source missing
    if [[ ! -e "$SRC" ]]; then
        echo -e "${RED}Source not found. Skipping.${NC}"
        return
    fi

    # Prevent nested folders
    if [[ -e "$DEST" ]]; then
        echo -e "${RED}Destination already exists on external drive.${NC}"
        echo -e "${RED}Skipping to prevent nested folders.${NC}"
        return
    fi

    echo "Moving data to external drive..."
    echo "(This may take several minutes depending on folder size)"

    # mv across volumes safely performs copy + delete
    mv "$SRC" "$DEST"

    # Remove leftover broken symlink if needed
    if [[ -L "$SRC" ]]; then
        rm "$SRC"
    fi

    echo "Creating symlink..."

    ln -s "$DEST" "$SRC"

    echo -e "${GREEN}Done.${NC}"
}

# ---------- Xcode ----------

echo ""
echo -e "${BLUE}Moving Xcode data...${NC}"

move_and_link \
"$HOME/Library/Developer/Xcode/DerivedData" \
"$EXTERNAL_BASE/Xcode"

move_and_link \
"$HOME/Library/Developer/Xcode/Archives" \
"$EXTERNAL_BASE/Xcode"

# Optional Products
if [[ -d "$HOME/Library/Developer/Xcode/Products" ]]; then
    move_and_link \
    "$HOME/Library/Developer/Xcode/Products" \
    "$EXTERNAL_BASE/Xcode"
fi

# ---------- Android ----------

echo ""
echo -e "${BLUE}Moving Android data...${NC}"

move_and_link \
"$HOME/.gradle" \
"$EXTERNAL_BASE/Android"

move_and_link \
"$HOME/Library/Android/sdk" \
"$EXTERNAL_BASE/Android"

if [[ -d "$HOME/.android/avd" ]]; then
    move_and_link \
    "$HOME/.android/avd" \
    "$EXTERNAL_BASE/Android"
fi

# ---------- Permissions ----------

echo ""
echo -e "${BLUE}Setting permissions...${NC}"

chown -R "$(whoami)":staff "$EXTERNAL_BASE" 2>/dev/null || true
chmod -R 700 "$EXTERNAL_BASE"

# ---------- Verify ----------

echo ""
echo -e "${BLUE}Verifying symlinks...${NC}"

echo ""

[[ -L "$HOME/Library/Developer/Xcode/DerivedData" ]] \
&& echo "✓ DerivedData symlink OK"

[[ -L "$HOME/Library/Developer/Xcode/Archives" ]] \
&& echo "✓ Archives symlink OK"

[[ -L "$HOME/Library/Developer/Xcode/Products" ]] \
&& echo "✓ Products symlink OK"

[[ -L "$HOME/.gradle" ]] \
&& echo "✓ .gradle symlink OK"

[[ -L "$HOME/Library/Android/sdk" ]] \
&& echo "✓ Android SDK symlink OK"

[[ -L "$HOME/.android/avd" ]] \
&& echo "✓ Android AVD symlink OK"

# ---------- Open Finder ----------

open "/Volumes/${DRIVE_NAME}/Developer"

# ---------- Complete ----------

echo ""
echo -e "${GREEN}=============================================="
echo " Setup Completed Successfully!"
echo -e "==============================================${NC}"

osascript -e 'display notification "Flutter external storage setup completed." with title "Setup Finished"'

echo ""
echo -e "${YELLOW}IMPORTANT:${NC}"
echo "Always connect the external drive BEFORE:"
echo "• Xcode"
echo "• Android Studio"
echo "• Flutter"
echo "• Simulators"

echo ""
read -p "Press ENTER to close..."