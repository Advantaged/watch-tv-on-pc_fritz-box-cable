#!/bin/bash
# sort-all-lists.sh

# Generate log filename with preferred format
LOGFILE="$(date '+%Y-%m-%d_T_%H-%M-%S')_protocol.log"
exec &> "$LOGFILE"

# Define bold text using tput
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

# Make the scripts executable
chmod +x sort-radio-list.sh sort-tvhd-list.sh sort-tvsd-list.sh

# Execute scripts and handle errors
for script in sort-radio-list.sh sort-tvhd-list.sh sort-tvsd-list.sh; do
    if [[ -x "$script" ]]; then
        echo "Running $script..."
        if ./"$script"; then
            echo "✅ Successfully executed: $script"
        else
            echo "❌ Failed to execute: $script (error code: $?)"
        fi
    else
        echo "⚠️  Cannot execute $script: not found or not executable"
    fi
done

# Prompt user with bolded keys and default to Enter/y/Y
echo
read -p "Type ${BOLD}y${NORMAL} or ${BOLD}Y${NORMAL} or just hit ${BOLD}Enter${NORMAL} to close the terminal, type ${BOLD}n${NORMAL} or ${BOLD}N${NORMAL} to keep it open: " choice
case "${choice:-y}" in
    [Yy]|"") exit 0 ;;
    [Nn]) echo "Terminal remains open." ;;
    *) echo "Invalid input. Terminal remains open." ;;
esac
