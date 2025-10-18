#!/bin/bash

# merge-m3u.sh - Simple and reliable merge script
# Usage: ./merge-m3u.sh <hd_directory> <sd_directory>

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
    local hd_dir="$1" sd_dir="$2"
    local merged_dir="${hd_dir%_tvhd}_merged"

    # Create directories
    mkdir -p "$merged_dir/staging" "$merged_dir/duplicates" "$merged_dir/titles"

    # Initialize log
    local log="$merged_dir/processing.log"
    echo "Merge Log - $(date)" > "$log"

    print_status "Starting merge process..."

    # Step 1: Copy ALL files to staging
    print_status "Step 1: Copying ALL files to staging..."

    # Copy HD files
    for file in "$hd_dir/titles/"*.channel; do
        if [[ -f "$file" ]]; then
            cp "$file" "$merged_dir/staging/"
            echo "COPIED HD: $(basename "$file") to staging" >> "$log"
        fi
    done

    # Copy SD files
    for file in "$sd_dir/titles/"*.channel; do
        if [[ -f "$file" ]]; then
            cp "$file" "$merged_dir/staging/"
            echo "COPIED SD: $(basename "$file") to staging" >> "$log"
        fi
    done

    local staging_count=$(ls "$merged_dir/staging/"*.channel 2>/dev/null | wc -l)
    print_status "Staging complete: $staging_count files"

    # Step 2: Process each file individually
    print_status "Step 2: Processing files..."

    # Process HD files first
    for hd_file in "$merged_dir/staging/"*_hd.channel; do
        if [[ -f "$hd_file" ]]; then
            local hd_name=$(basename "$hd_file")
            cp "$hd_file" "$merged_dir/titles/"
            echo "HD TO TITLES: $hd_name" >> "$log"
        fi
    done

    # Process SD files
    for sd_file in "$merged_dir/staging/"*.channel; do
        if [[ -f "$sd_file" ]]; then
            local sd_name=$(basename "$sd_file")
            # Skip HD files
            [[ "$sd_name" == *"_hd.channel" ]] && continue

            local base_name="${sd_name%.channel}"
            base_name="${base_name%_sd}"
            local hd_version="${base_name}_hd.channel"

            if [[ -f "$merged_dir/staging/$hd_version" ]]; then
                cp "$sd_file" "$merged_dir/duplicates/"
                echo "DUPLICATE SD: $sd_name -> duplicates (HD exists)" >> "$log"
            else
                cp "$sd_file" "$merged_dir/titles/"
                echo "UNIQUE SD: $sd_name -> titles" >> "$log"
            fi
        fi
    done

    # Step 3: Generate M3U
    print_status "Step 3: Generating M3U..."
    echo "#EXTM3U" > "$merged_dir/merged-tv.m3u"

    for file in "$merged_dir/titles/"*.channel; do
        if [[ -f "$file" ]]; then
            cat "$file" >> "$merged_dir/merged-tv.m3u"
            echo "" >> "$merged_dir/merged-tv.m3u"
        fi
    done

    # Final counts
    local hd_count=$(ls "$hd_dir/titles/"*.channel 2>/dev/null | wc -l)
    local sd_count=$(ls "$sd_dir/titles/"*.channel 2>/dev/null | wc -l)
    local final_count=$(ls "$merged_dir/titles/"*.channel 2>/dev/null | wc -l)
    local dup_count=$(ls "$merged_dir/duplicates/"*.channel 2>/dev/null | wc -l)

    print_success "Complete!"
    echo ""
    echo "Results:"
    echo "  HD files: $hd_count"
    echo "  SD files: $sd_count"
    echo "  Duplicates: $dup_count"
    echo "  Final titles: $final_count"
    echo ""
    echo "Check the log: $log"
    echo "Verify folders:"
    echo "  staging/: $staging_count files"
    echo "  titles/: $final_count files"
    echo "  duplicates/: $dup_count files"
}

# Check arguments and run
if [[ $# -ne 2 ]]; then
    print_error "Usage: $0 <hd_directory> <sd_directory>"
    exit 1
fi

main "$@"
