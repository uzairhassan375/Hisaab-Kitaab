# App Icon Setup Guide

This guide explains where to place your app icon files for different platforms.

## 📱 Icon Requirements

### For Android
You need to create icons in multiple sizes and place them in the following directories:

**Location:** `android/app/src/main/res/`

Replace the existing `ic_launcher.png` files in these folders:

1. **mipmap-mdpi/** - 48x48 pixels
2. **mipmap-hdpi/** - 72x72 pixels
3. **mipmap-xhdpi/** - 96x96 pixels
4. **mipmap-xxhdpi/** - 144x144 pixels
5. **mipmap-xxxhdpi/** - 192x192 pixels

**File name:** `ic_launcher.png` (for each folder)

### For iOS
You need multiple icon sizes for different devices:

**Location:** `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

Replace the existing files with these sizes:

- **Icon-App-20x20@1x.png** - 20x20 pixels
- **Icon-App-20x20@2x.png** - 40x40 pixels
- **Icon-App-20x20@3x.png** - 60x60 pixels
- **Icon-App-29x29@1x.png** - 29x29 pixels
- **Icon-App-29x29@2x.png** - 58x58 pixels
- **Icon-App-29x29@3x.png** - 87x87 pixels
- **Icon-App-40x40@1x.png** - 40x40 pixels
- **Icon-App-40x40@2x.png** - 80x80 pixels
- **Icon-App-40x40@3x.png** - 120x120 pixels
- **Icon-App-60x60@2x.png** - 120x120 pixels
- **Icon-App-60x60@3x.png** - 180x180 pixels
- **Icon-App-76x76@1x.png** - 76x76 pixels
- **Icon-App-76x76@2x.png** - 152x152 pixels
- **Icon-App-83.5x83.5@2x.png** - 167x167 pixels
- **Icon-App-1024x1024@1x.png** - 1024x1024 pixels (App Store)

### For Web
**Location:** `web/`

- **favicon.png** - 48x48 pixels (or any square size)
- **icons/Icon-192.png** - 192x192 pixels
- **icons/Icon-512.png** - 512x512 pixels
- **icons/Icon-maskable-192.png** - 192x192 pixels (maskable)
- **icons/Icon-maskable-512.png** - 512x512 pixels (maskable)

### For Windows
**Location:** `windows/runner/resources/`

- **app_icon.ico** - ICO format (can contain multiple sizes: 16x16, 32x32, 48x48, 256x256)

## 🛠️ Easy Method: Using Flutter Launcher Icons Package

The easiest way to set up icons is using the `flutter_launcher_icons` package:

### Step 1: Add the package to `pubspec.yaml`

Add this to your `dev_dependencies` section:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  flutter_launcher_icons: ^0.13.1
```

### Step 2: Configure in `pubspec.yaml`

Add this configuration at the end of `pubspec.yaml`:

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  web:
    generate: true
  image_path: "assets/icon/app_icon.png"  # Path to your icon (1024x1024 recommended)
  adaptive_icon_background: "#2196F3"  # Background color for Android adaptive icon
  adaptive_icon_foreground: "assets/icon/app_icon.png"  # Foreground icon
```

### Step 3: Create your icon

1. Create a folder: `assets/icon/`
2. Place your icon there as `app_icon.png` (1024x1024 pixels recommended)
3. Make sure it's a square PNG with transparent background (or solid color)

### Step 4: Run the generator

```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

This will automatically generate all required icon sizes for all platforms!

## 📝 Manual Method

If you prefer to do it manually:

### 1. Create your base icon
- Size: 1024x1024 pixels
- Format: PNG
- Background: Transparent or solid color
- Design: Simple, recognizable, works at small sizes

### 2. Generate different sizes
Use an online tool like:
- https://www.appicon.co/
- https://icon.kitchen/
- https://makeappicon.com/

Or use image editing software to resize.

### 3. Replace the files
- Replace all the existing icon files in the directories mentioned above
- Keep the exact same file names
- Make sure formats match (PNG for most, ICO for Windows)

## ✅ Quick Checklist

- [ ] Create 1024x1024 base icon
- [ ] Generate Android icons (5 sizes)
- [ ] Generate iOS icons (14 sizes)
- [ ] Generate Web icons (5 files)
- [ ] Generate Windows icon (ICO format)
- [ ] Replace all existing icon files
- [ ] Test on device/emulator

## 🎨 Icon Design Tips

1. **Keep it simple** - Icons are viewed at small sizes
2. **Use high contrast** - Should be visible on light and dark backgrounds
3. **Avoid text** - Text becomes unreadable at small sizes
4. **Test at small sizes** - Make sure it's recognizable at 48x48 pixels
5. **Use appropriate colors** - Match your app's theme (blue for this app)

## 🔄 After Changing Icons

1. **Android:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **iOS:**
   ```bash
   cd ios
   pod install
   cd ..
   flutter clean
   flutter run
   ```

3. **Web:**
   ```bash
   flutter clean
   flutter build web
   ```

## 📁 Current Icon Locations

Your current icons are located at:

- **Android:** `android/app/src/main/res/mipmap-*/ic_launcher.png`
- **iOS:** `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-*.png`
- **Web:** `web/icons/` and `web/favicon.png`
- **Windows:** `windows/runner/resources/app_icon.ico`

## 💡 Recommended: Use flutter_launcher_icons

The `flutter_launcher_icons` package is the easiest and most reliable method. It handles all the complexity of generating multiple sizes and placing them in the correct locations automatically.


