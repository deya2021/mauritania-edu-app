# Arabic Fonts for Mauritania Edu App

This directory contains the required fonts for proper Arabic (RTL) and French text rendering.

## Required Fonts

### For Arabic Text (RTL Support)
- **Cairo-Regular.ttf** - Regular weight for body text
- **Cairo-Bold.ttf** - Bold weight for headings

### For French Text
- **Roboto-Regular.ttf** - Regular weight for body text
- **Roboto-Bold.ttf** - Bold weight for headings

## How to Add Fonts

### Option 1: Download from Google Fonts (Recommended)

#### Cairo Font (Arabic)
1. Visit: https://fonts.google.com/specimen/Cairo
2. Click "Download family"
3. Extract and copy:
   - Cairo-Regular.ttf
   - Cairo-Bold.ttf
4. Place in this directory

#### Roboto Font (French)
1. Visit: https://fonts.google.com/specimen/Roboto
2. Click "Download family"
3. Extract and copy:
   - Roboto-Regular.ttf
   - Roboto-Bold.ttf
4. Place in this directory

### Option 2: Use System Fonts (Fallback)

If you don't add custom fonts, the app will use system default fonts. This works but may not look as polished.

### Option 3: Use Flutter's Built-in Fonts

For testing, you can use Material Design's default fonts by removing the font declarations in `pubspec.yaml`.

## Font Licenses

- **Cairo**: Open Font License (OFL)
- **Roboto**: Apache License 2.0

Both are free for commercial use.

## File Structure

```
assets/fonts/
├── Cairo-Regular.ttf
├── Cairo-Bold.ttf
├── Roboto-Regular.ttf
├── Roboto-Bold.ttf
└── FONTS_README.md (this file)
```

## Installation Steps

1. Download fonts from Google Fonts
2. Copy .ttf files to this directory
3. Ensure pubspec.yaml references them correctly
4. Run: `flutter pub get`
5. Rebuild app: `flutter clean && flutter build`

## Troubleshooting

If fonts don't display:
1. Check file names match exactly in pubspec.yaml
2. Run `flutter clean`
3. Run `flutter pub get`
4. Rebuild the app

## Alternative: Use Package

Instead of adding font files, you can use:
```yaml
dependencies:
  google_fonts: ^6.1.0
```

Then in code:
```dart
import 'package:google_fonts/google_fonts.dart';

textTheme: GoogleFonts.cairoTextTheme(),
```

This downloads fonts at runtime.
