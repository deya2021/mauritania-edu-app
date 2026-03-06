# App Icon for Mauritania Edu

## Required Icon File

Place your app icon here: **app_icon.png**

### Specifications:
- **Format**: PNG with transparency
- **Size**: 1024x1024 pixels (minimum)
- **Design**: Simple, recognizable icon
- **Colors**: Should work on light and dark backgrounds

## Icon Design Suggestions

### Concept Ideas:
1. **Book + Mauritania Flag Colors**
   - Open book with green/yellow/red accents
   
2. **Graduation Cap + Arabic Letter**
   - Cap with ع or أ underneath
   
3. **School Building + Crescent**
   - Simple mosque-like school building
   
4. **Pen + Stars**
   - Writing pen with stars representing education

### Design Tools:
- **Canva** (free, easy): https://www.canva.com
- **Figma** (professional): https://www.figma.com
- **GIMP** (free desktop): https://www.gimp.org
- **Hire designer**: Fiverr ($5-20)

## Generation Process

Once you have `app_icon.png` in this directory:

```bash
# Install flutter_launcher_icons
flutter pub get

# Generate all icon sizes
flutter pub run flutter_launcher_icons

# This will create:
# - Android icons (all densities)
# - iOS icons (all sizes)
# - Web favicon
# - Windows icon
```

## Icon Sizes Generated

### Android:
- mipmap-mdpi: 48x48
- mipmap-hdpi: 72x72
- mipmap-xhdpi: 96x96
- mipmap-xxhdpi: 144x144
- mipmap-xxxhdpi: 192x192

### iOS:
- 20x20 @1x, @2x, @3x
- 29x29 @1x, @2x, @3x
- 40x40 @1x, @2x, @3x
- 60x60 @2x, @3x
- 76x76 @1x, @2x
- 83.5x83.5 @2x
- 1024x1024 @1x

### Web:
- favicon.png
- icons/Icon-192.png
- icons/Icon-512.png

## Quick Start (Without Custom Icon)

If you want to test without a custom icon:

1. Use a placeholder from: https://placeholder.com/
2. Download a 1024x1024 colored square
3. Name it `app_icon.png`
4. Run icon generation

## Example Placeholder Command:

```bash
# Download placeholder (requires curl/wget)
curl "https://via.placeholder.com/1024/2196F3/FFFFFF?text=Edu" -o app_icon.png
```

## Current Status:

⚠️ **app_icon.png NOT FOUND**

Please add your icon file here to generate all platform icons.

## After Adding Icon:

```bash
flutter pub get
flutter pub run flutter_launcher_icons
flutter clean
flutter build apk  # or ios
```

Your app will now have proper icons on all platforms!
