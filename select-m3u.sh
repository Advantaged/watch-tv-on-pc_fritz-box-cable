#!/bin/bash
# select-m3u.sh - Erstellt eine Playlist aus manuell ausgewählten Kanälen

set -euo pipefail

BLUE='\033[0;34m'; GREEN='\033[0;32m'; NC='\033[0m'
print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }

main() {
    local selected_dir="$1"
    local selected_folder="$selected_dir/selected"
    local output_playlist="$selected_dir/selected-tv.m3u"

    if [[ ! -d "$selected_folder" ]]; then
        echo "Fehler: Ordner $selected_folder nicht gefunden!"; exit 1
    fi

    print_status "Erstelle Playlist: $output_playlist"
    echo "#EXTM3U" > "$output_playlist"

    # Alphabetische Sortierung der ausgewählten Dateien
    find "$selected_folder" -name "*.channel" | sort -f | while read -r channel_file; do
        cat "$channel_file" >> "$output_playlist"
        echo "" >> "$output_playlist" # Trennung
    done

    local count=$(grep -c "#EXTINF" "$output_playlist" || echo 0)
    echo -e "${GREEN}[ERFOLG]${NC} $count Sender in die Auswahl übernommen."
}

if [[ $# -ne 1 ]]; then echo "Nutzung: $0 <verzeichnis>"; exit 1; fi
main "$@"
