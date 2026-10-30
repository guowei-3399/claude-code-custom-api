#!/bin/bash
# Icon Generation Script
# Converts icon.svg to all required formats and sizes
#
# Dependencies:
#   - ImageMagick (convert)
#   - Inkscape or rsvg-convert (for SVG to PNG)
#   - icotool (for .ico) or ImageMagick
#   - png2icns (for macOS .icns)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SVG_FILE="$SCRIPT_DIR/icon.svg"
OUTPUT_DIR="$SCRIPT_DIR"

echo "=========================================="
echo "  Icon Generation for Claude Launcher"
echo "=========================================="
echo ""

# Check if SVG exists
if [ ! -f "$SVG_FILE" ]; then
  echo "Error: icon.svg not found at $SVG_FILE"
  exit 1
fi

# Check dependencies
if ! command -v convert &> /dev/null; then
  echo "Warning: ImageMagick not found. Install with:"
  echo "  - Ubuntu/Debian: sudo apt-get install imagemagick"
  echo "  - macOS: brew install imagemagick"
  echo "  - Windows: choco install imagemagick"
fi

# Function to convert SVG to PNG
svg_to_png() {
  local size=$1
  local output=$2

  echo "Generating ${size}x${size} PNG..."

  # Try different converters
  if command -v inkscape &> /dev/null; then
    inkscape -w $size -h $size "$SVG_FILE" -o "$output" 2>/dev/null
  elif command -v rsvg-convert &> /dev/null; then
    rsvg-convert -w $size -h $size "$SVG_FILE" -o "$output"
  elif command -v convert &> /dev/null; then
    convert -background none -density 600 -resize ${size}x${size} "$SVG_FILE" "$output"
  else
    echo "Error: No SVG converter found (inkscape, rsvg-convert, or ImageMagick)"
    echo "Please use online converter: https://cloudconvert.com/svg-to-png"
    return 1
  fi
}

# Generate PNGs for different platforms
echo ""
echo "Generating PNG files..."

# Standard sizes
svg_to_png 16 "$OUTPUT_DIR/icon-16.png"
svg_to_png 32 "$OUTPUT_DIR/icon-32.png"
svg_to_png 48 "$OUTPUT_DIR/icon-48.png"
svg_to_png 64 "$OUTPUT_DIR/icon-64.png"
svg_to_png 128 "$OUTPUT_DIR/icon-128.png"
svg_to_png 256 "$OUTPUT_DIR/icon-256.png"
svg_to_png 512 "$OUTPUT_DIR/icon-512.png"
svg_to_png 1024 "$OUTPUT_DIR/icon-1024.png"

# Main icon.png (used by Linux)
cp "$OUTPUT_DIR/icon-512.png" "$OUTPUT_DIR/icon.png"

echo ""
echo "Generating Windows .ico file..."

# Windows .ico (multi-resolution)
if command -v convert &> /dev/null; then
  convert "$OUTPUT_DIR/icon-16.png" \
          "$OUTPUT_DIR/icon-32.png" \
          "$OUTPUT_DIR/icon-48.png" \
          "$OUTPUT_DIR/icon-64.png" \
          "$OUTPUT_DIR/icon-128.png" \
          "$OUTPUT_DIR/icon-256.png" \
          "$OUTPUT_DIR/icon.ico"
  echo "✓ icon.ico created"
else
  echo "⚠️  ImageMagick not found, skipping .ico generation"
  echo "   Use online converter: https://convertio.co/png-ico/"
  echo "   Upload icon-256.png"
fi

echo ""
echo "Generating macOS .icns file..."

# macOS .icns
if command -v png2icns &> /dev/null; then
  png2icns "$OUTPUT_DIR/icon.icns" \
           "$OUTPUT_DIR/icon-16.png" \
           "$OUTPUT_DIR/icon-32.png" \
           "$OUTPUT_DIR/icon-64.png" \
           "$OUTPUT_DIR/icon-128.png" \
           "$OUTPUT_DIR/icon-256.png" \
           "$OUTPUT_DIR/icon-512.png" \
           "$OUTPUT_DIR/icon-1024.png"
  echo "✓ icon.icns created"
elif command -v iconutil &> /dev/null; then
  # macOS native iconutil
  ICONSET_DIR="$OUTPUT_DIR/icon.iconset"
  mkdir -p "$ICONSET_DIR"

  cp "$OUTPUT_DIR/icon-16.png" "$ICONSET_DIR/icon_16x16.png"
  cp "$OUTPUT_DIR/icon-32.png" "$ICONSET_DIR/icon_16x16@2x.png"
  cp "$OUTPUT_DIR/icon-32.png" "$ICONSET_DIR/icon_32x32.png"
  cp "$OUTPUT_DIR/icon-64.png" "$ICONSET_DIR/icon_32x32@2x.png"
  cp "$OUTPUT_DIR/icon-128.png" "$ICONSET_DIR/icon_128x128.png"
  cp "$OUTPUT_DIR/icon-256.png" "$ICONSET_DIR/icon_128x128@2x.png"
  cp "$OUTPUT_DIR/icon-256.png" "$ICONSET_DIR/icon_256x256.png"
  cp "$OUTPUT_DIR/icon-512.png" "$ICONSET_DIR/icon_256x256@2x.png"
  cp "$OUTPUT_DIR/icon-512.png" "$ICONSET_DIR/icon_512x512.png"
  cp "$OUTPUT_DIR/icon-1024.png" "$ICONSET_DIR/icon_512x512@2x.png"

  iconutil -c icns "$ICONSET_DIR" -o "$OUTPUT_DIR/icon.icns"
  rm -rf "$ICONSET_DIR"
  echo "✓ icon.icns created"
else
  echo "⚠️  png2icns or iconutil not found, skipping .icns generation"
  echo "   Use online converter: https://cloudconvert.com/png-to-icns"
  echo "   Upload icon-1024.png"
fi

echo ""
echo "=========================================="
echo "  Icon Generation Complete!"
echo "=========================================="
echo ""
echo "Generated files:"
echo "  - icon.svg         (source file)"
echo "  - icon.png         (512x512, for Linux)"
echo "  - icon.ico         (multi-res, for Windows)"
echo "  - icon.icns        (multi-res, for macOS)"
echo "  - icon-*.png       (individual sizes)"
echo ""
echo "Electron-builder will automatically use:"
echo "  - Windows: icon.ico"
echo "  - macOS:   icon.icns"
echo "  - Linux:   icon.png"
echo ""
