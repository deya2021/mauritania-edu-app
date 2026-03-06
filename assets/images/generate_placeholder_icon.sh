#!/bin/bash

# Generate a placeholder app icon using ImageMagick (if available)
# This creates a simple 1024x1024 icon with the app name

# Check if ImageMagick is installed
if command -v convert &> /dev/null; then
    echo "Generating placeholder app icon..."
    
    convert -size 1024x1024 xc:#2196F3 \
        -gravity center \
        -pointsize 200 \
        -fill white \
        -font Arial-Bold \
        -annotate +0-100 "🎓" \
        -pointsize 80 \
        -annotate +0+80 "Mauritania" \
        -annotate +0+160 "Edu" \
        app_icon.png
    
    echo "✅ Placeholder icon created: app_icon.png"
    echo "Now run: flutter pub run flutter_launcher_icons"
else
    echo "⚠️ ImageMagick not installed."
    echo ""
    echo "Please either:"
    echo "1. Install ImageMagick: sudo apt-get install imagemagick"
    echo "2. Or download a placeholder from: https://via.placeholder.com/1024/2196F3/FFFFFF?text=Edu"
    echo "3. Or create your own 1024x1024 icon and save as app_icon.png"
fi
