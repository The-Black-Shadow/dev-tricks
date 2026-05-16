# Move Xcode & Android Cache/Data to External Drive (Safe Setup)

This guide helps move large development cache/build folders from your internal SSD to an external drive safely using symlinks. **This guide is specifically tailored for Flutter development for Android and iOS.**

This setup is designed for:

- Flutter developers
- iOS + Android development
- macOS users with limited internal storage

It avoids moving sensitive Apple simulator infrastructure that can corrupt Xcode.

---

## 🚀 Automated Setup (Recommended)

An interactive, automated macOS `.command` script is included to safely handle this process for you. 

1. Simply double-click `setup_dev_storage.command` in Finder to run it.
2. If macOS prevents it from running, you can make it executable via terminal first:
   ```bash
   chmod +x setup_dev_storage.command
   ```
   *(Note: The script in this repository already has executable permissions).*

The script will:
- Check for running IDEs to prevent corruption
- Auto-detect your external drives
- Prompt you to select the correct drive
- Move your Xcode and Android caches safely
- Create the necessary symlinks
- Set proper permissions

**Prefer to do it manually? Follow the manual guide below.**

---

# ⚠️ Important Notes

Your external drive MUST be:

- APFS formatted
- mounted with the SAME exact name every time
- connected BEFORE opening:
  - Xcode
  - Android Studio
  - Flutter
  - iOS Simulator
  - Android Emulator

---

# 0. Find Your Exact External Drive Name

Before running any commands, check the exact mounted drive name:

```bash
ls /Volumes
```

Example output:

```bash
Extranal
Macintosh HD
```

In this guide, the drive name is:

```bash
Extranal
```

Replace it everywhere if your drive has a different name.

---

# ✅ Safe Folders to Move

## Xcode

- DerivedData
- Archives
- Products (optional)

## Android

- .gradle
- Android SDK
- Android AVD (emulators)

---

# ❌ Do NOT Move These

Avoid moving or symlinking:

```bash
~/Library/Developer
~/Library/Developer/CoreSimulator
~/Library/Developer/Xcode/UserData
```

Moving those can break:

- Xcode
- iOS Simulators
- DerivedData
- CoreSimulator services

---

# 1. Create External Folders

```bash
mkdir -p /Volumes/Extranal/Developer/Xcode
mkdir -p /Volumes/Extranal/Developer/Android
```

---

# 2. Move Safe Xcode Cache Folders

```bash
mv ~/Library/Developer/Xcode/DerivedData /Volumes/Extranal/Developer/Xcode/
mv ~/Library/Developer/Xcode/Archives /Volumes/Extranal/Developer/Xcode/
```

Optional:

```bash
mv ~/Library/Developer/Xcode/Products /Volumes/Extranal/Developer/Xcode/
```

---

# 3. Create Xcode Symlinks

```bash
ln -s /Volumes/Extranal/Developer/Xcode/DerivedData ~/Library/Developer/Xcode/DerivedData
ln -s /Volumes/Extranal/Developer/Xcode/Archives ~/Library/Developer/Xcode/Archives
```

Optional:

```bash
ln -s /Volumes/Extranal/Developer/Xcode/Products ~/Library/Developer/Xcode/Products
```

---

# 4. Move Android Data

```bash
mv ~/.gradle /Volumes/Extranal/Developer/Android/
mv ~/Library/Android/sdk /Volumes/Extranal/Developer/Android/
mv ~/.android/avd /Volumes/Extranal/Developer/Android/
```

---

# 5. Create Android Symlinks

```bash
ln -s /Volumes/Extranal/Developer/Android/.gradle ~/.gradle
ln -s /Volumes/Extranal/Developer/Android/sdk ~/Library/Android/sdk
ln -s /Volumes/Extranal/Developer/Android/avd ~/.android/avd
```

---

# 6. Restrict Access (Optional but Recommended)

If multiple users use the same Mac/external drive:

```bash
sudo chown -R $(whoami):staff /Volumes/Extranal/Developer
chmod -R 700 /Volumes/Extranal/Developer
```

This allows:

- only your macOS user account to access the files
- prevents other users from browsing/deleting normally

---

# 7. Verify Symlinks

Run:

```bash
ls -la ~/Library/Developer/Xcode
ls -la ~/.gradle
ls -la ~/Library/Android
ls -la ~/.android
```

You should see arrows like:

```bash
DerivedData -> /Volumes/Extranal/...
Archives -> /Volumes/Extranal/...
Products -> /Volumes/Extranal/...
sdk -> /Volumes/Extranal/...
avd -> /Volumes/Extranal/...
```

The `->` means the symlink is working correctly.

---

# 8. Verify External Folders

```bash
ls -la /Volumes/Extranal/Developer/Xcode
ls -la /Volumes/Extranal/Developer/Android
```

---

# 9. Health Check

Check all Xcode symlinks:

```bash
find ~/Library/Developer/Xcode -maxdepth 1 -type l -ls
```

Example output:

```bash
DerivedData -> /Volumes/Extranal/Developer/Xcode/DerivedData
Archives -> /Volumes/Extranal/Developer/Xcode/Archives
Products -> /Volumes/Extranal/Developer/Xcode/Products
```

---

# 10. Test Everything

## Flutter

```bash
flutter doctor
flutter build ios
```

## Android Emulator

```bash
flutter emulators
```

## iOS Simulator

```bash
open -a Simulator
```

---

# ⚠️ Important Warnings

## Never Open IDEs Without External Drive Connected

If the drive is disconnected:

- Xcode may recreate local folders
- Android Studio may regenerate caches
- symlinks may break

Always connect the drive first.

---

## Avoid ExFAT

Recommended:

- APFS

Avoid:

- ExFAT
- NTFS

for development caches/build systems.

---

# ✅ Recommended Final Structure

Safe external setup:

```bash
/Volumes/Extranal/Developer/
├── Xcode
│   ├── Archives
│   ├── DerivedData
│   └── Products
└── Android
    ├── .gradle
    ├── sdk
    └── avd
```

This setup provides:

- reduced internal SSD usage
- stable Xcode/iOS simulator behavior
- safer Flutter development
- clean symlink architecture
