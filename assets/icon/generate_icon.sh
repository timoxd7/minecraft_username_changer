#!/bin/bash
# Generate a Minecraft-style username changer icon
# Green background (Minecraft grass block inspired) with a white user/person silhouette

# Create base icon - green gradient background with pixelated look
convert -size 1024x1024 xc:none \
  -fill "#5D9B47" -draw "rectangle 0,0 1024,1024" \
  -fill "#7CB342" -draw "rectangle 64,64 960,448" \
  -fill "#4CAF50" -draw "rectangle 128,128 896,384" \
  \( -size 1024x1024 xc:none \
     -fill "white" \
     -draw "circle 512,340 512,200" \
     -draw "roundrectangle 312,480 712,820 40,40" \
  \) -composite \
  \( -size 1024x1024 xc:none \
     -fill "#FFD54F" \
     -stroke "#FF8F00" -strokewidth 20 \
     -draw "path 'M 720,580 L 820,480 L 870,530 L 770,630 Z'" \
     -draw "path 'M 870,530 L 920,480 L 870,430 L 820,480 Z'" \
     -fill "#795548" \
     -draw "rectangle 700,620 750,720" \
  \) -composite \
  icon_1024.png

# Generate all required sizes for macOS
for size in 16 32 64 128 256 512 1024; do
  convert icon_1024.png -resize ${size}x${size} app_icon_${size}.png
done

# Copy to macOS assets
cp app_icon_16.png ../macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_16.png
cp app_icon_32.png ../macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_32.png
cp app_icon_64.png ../macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_64.png
cp app_icon_128.png ../macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_128.png
cp app_icon_256.png ../macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_256.png
cp app_icon_512.png ../macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_512.png
cp app_icon_1024.png ../macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_1024.png

echo "Icons generated successfully!"
