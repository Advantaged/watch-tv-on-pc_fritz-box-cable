#!/bin/bash

# sort-m3u.sh

# Check if input files are provided
if [ $# -eq 0 ]; then
    echo "Error: No input files specified"
    echo "Usage: $0 file1 file2 file3 ..."
    exit 1
fi

# Process each input file
for input_arg in "$@"; do
    echo "Processing: $input_arg"

    # Handle input file with or without extension
    if [[ -f "$input_arg" ]]; then
        input_file="$input_arg"
    elif [[ -f "$input_arg.m3u" ]]; then
        input_file="$input_arg.m3u"
    else
        echo "Error: Input file '$input_arg' or '$input_arg.m3u' not found"
        continue  # Skip to next file instead of exiting
    fi

    # Generate timestamp and folder structure
    timestamp=$(date '+%Y-%m-%d_%H-%M-%S')
    base_name=$(basename "$input_file" .m3u)
    output_dir="${timestamp}_${base_name}"
    titles_dir="${output_dir}/titles"

    # Create output directories
    mkdir -p "$output_dir" "$titles_dir"

    # Define output files
    log_file="${output_dir}/processing.log"
    sorted_file="${output_dir}/sorted_${base_name}.m3u"

    # Initialize log file
    {
        echo "M3U Channel Sorting Log - $(date)"
        echo "Input: $input_file"
        echo "Output directory: $output_dir"
        echo "Titles directory: $titles_dir"
        echo "========================================"
    } > "$log_file"

    # Check for M3U header
    first_line=$(head -n1 "$input_file")
    if [[ "$first_line" != "#EXTM3U" ]]; then
        echo "Warning: Missing #EXTM3U header" | tee -a "$log_file"
        has_header=false
    else
        has_header=true
        echo "Found M3U header" >> "$log_file"
    fi

    # Process the file
    echo "Processing channels..." | tee -a "$log_file"
    channel_count=0
    incomplete_count=0
    line_number=0

    # Read the file line by line
    while IFS= read -r line || [ -n "$line" ]; do
        line_number=$((line_number + 1))

        # Look for #EXTINF lines
        if [[ "$line" =~ ^#EXTINF: ]]; then
            # Extract channel name (everything after the last comma)
            channel_name=$(echo "$line" | sed 's/.*,//')

            # Remove or replace problematic characters for filename
            safe_filename=$(echo "$channel_name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-zA-Z0-9._-]/_/g')

            # Read the next two lines
            if IFS= read -r buffer_line && IFS= read -r url_line; then
                line_number=$((line_number + 2))

                # Validate the chunk structure
                if [[ "$buffer_line" =~ ^#EXTVLCOPT: ]] && [[ "$url_line" =~ ^[a-zA-Z]+:// ]]; then
                    # Create individual channel file
                    channel_file="${titles_dir}/${safe_filename}.channel"
                    {
                        echo "$line"
                        echo "$buffer_line"
                        echo "$url_line"
                    } > "$channel_file"

                    channel_count=$((channel_count + 1))
                    echo "Created channel: $channel_name -> $safe_filename.channel" >> "$log_file"
                else
                    echo "Error: Invalid chunk structure at line $line_number" >> "$log_file"
                    echo "  Buffer line: $buffer_line" >> "$log_file"
                    echo "  URL line: $url_line" >> "$log_file"
                    incomplete_count=$((incomplete_count + 1))
                fi
            else
                echo "Error: Incomplete chunk for '$channel_name' at line $line_number" >> "$log_file"
                incomplete_count=$((incomplete_count + 1))
            fi
        fi
    done < "$input_file"

    echo "Created $channel_count channel files, $incomplete_count incomplete chunks" >> "$log_file"

    # Check if we have any channels
    if [ $channel_count -eq 0 ]; then
        echo "Error: No valid channels found in $input_file" | tee -a "$log_file"
        continue  # Skip to next file
    fi

    # Sort the channel files by filename (which is based on lowercase channel name)
    echo "Sorting channels..." | tee -a "$log_file"

    # Create sorted output file
    if [ "$has_header" = true ]; then
        echo "$first_line" > "$sorted_file"
    else
        echo "#EXTM3U" > "$sorted_file"
    fi

    # Add sorted channels to output file
    find "$titles_dir" -name "*.channel" -type f | sort -f | while read -r channel_file; do
        cat "$channel_file" >> "$sorted_file"
    done

    # Final summary for this file
    {
        echo ""
        echo "=== PROCESSING COMPLETE ==="
        echo "Successfully created sorted file: $sorted_file"
        echo "Total channels processed: $channel_count"
        echo "Incomplete channels: $incomplete_count"
        echo "Output directory: $output_dir"
        echo ""
        echo "Files created:"
        echo "  - $(basename "$sorted_file") (sorted output)"
        echo "  - titles/ (directory with individual channel files)"
        echo "  - $(basename "$log_file") (detailed processing log)"
    } >> "$log_file"

    echo "Completed: $input_file -> $sorted_file ($channel_count channels)" | tee -a "$log_file"
    echo "---"
done

echo "All files processed!"
