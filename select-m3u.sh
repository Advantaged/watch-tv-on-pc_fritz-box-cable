#!/bin/bash

# select-m3u.sh - Create playlist from selected channels
# Usage: ./select-m3u.sh <selected_directory>

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

main() {
    local selected_dir="$1"
    local selected_folder="$selected_dir/selected"
    local output_playlist="$selected_dir/selected-tv.m3u"

    # Check if selected folder exists
    if [[ ! -d "$selected_folder" ]]; then
        print_error "Selected folder not found: $selected_folder"
        exit 1
    fi

    # Check if there are any .channel files
    local channel_count=$(ls "$selected_folder"/*.channel 2>/dev/null | wc -l || echo 0)

    if [[ $channel_count -eq 0 ]]; then
        print_error "No .channel files found in $selected_folder"
        exit 1
    fi

    print_status "Found $channel_count channels in selected folder"

    # Create the M3U playlist
    print_status "Creating playlist: $output_playlist"

    # Start with M3U header
    echo "#EXTM3U" > "$output_playlist"

    # Add each channel file in alphabetical order
    for channel_file in $(ls "$selected_folder"/*.channel | sort); do
        if [[ -f "$channel_file" ]]; then
            cat "$channel_file" >> "$output_playlist"
            echo "" >> "$output_playlist"
            print_status "Added: $(basename "$channel_file")"
        fi
    done

    # Verify the result
    local entry_count=$(grep -c "#EXTINF" "$output_playlist" 2>/dev/null || echo 0)

    print_success "Playlist created successfully!"
    echo ""
    echo "Summary:"
    echo "  Selected channels: $channel_count"
    echo "  M3U entries: $entry_count"
    echo "  Output file: $output_playlist"

    # Show first few channels as preview
    print_status "First 5 channels in playlist:"
    grep "#EXTINF" "$output_playlist" | head -5 | while read line; do
        echo "  - ${line#*,}"
    done
}

# Check arguments and run
if [[ $# -ne 1 ]]; then
    print_error "Usage: $0 <selected_directory>"
    echo "Example: $0 2025-10-15_07-18-15_selected"
    exit 1
fi

main "$@"
