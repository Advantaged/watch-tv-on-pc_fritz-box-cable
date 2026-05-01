#!/bin/bash
# merge-m3u.sh - Kombiniert HD und SD Verzeichnisse ohne Duplikate

set -euo pipefail

BLUE='\033[0;34m'; GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'
print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

main() {
    local hd_dir="$1" sd_dir="$2"
    local merged_dir="${hd_dir}_merged"

    mkdir -p "$merged_dir/staging" "$merged_dir/duplicates" "$merged_dir/titles"
    local log="$merged_dir/processing.log"
    echo "Merge Log - $(date)" > "$log"

    print_status "Schritt 1: Kopiere alle Dateien in den Zwischenspeicher..."
    # Nutze find, um Leerzeichen in Dateinamen sicher zu händeln
    find "$hd_dir/titles/" -name "*.channel" -exec cp {} "$merged_dir/staging/" \;
    find "$sd_dir/titles/" -name "*.channel" -exec cp {} "$merged_dir/staging/" \;

    print_status "Schritt 2: HD-Vorrang wird geprüft..."
    # Zuerst alle HD-Versionen festlegen
    for hd_file in "$merged_dir/staging/"*_hd.channel; do
        [[ -e "$hd_file" ]] || continue
        cp "$hd_file" "$merged_dir/titles/"
    done

    # Dann SD-Versionen prüfen
    for sd_file in "$merged_dir/staging/"*.channel; do
        [[ -e "$sd_file" ]] || continue
        local name=$(basename "$sd_file")
        [[ "$name" == *"_hd.channel" ]] && continue

        local base="${name%.channel}"
        base="${base%_sd}"
        if [[ -f "$merged_dir/staging/${base}_hd.channel" ]]; then
            cp "$sd_file" "$merged_dir/duplicates/"
        else
            cp "$sd_file" "$merged_dir/titles/"
        fi
    done

    print_status "Schritt 3: Erstelle finale M3U..."
    echo "#EXTM3U" > "$merged_dir/merged-tv.m3u"
    find "$merged_dir/titles/" -name "*.channel" | sort -f | while read -r file; do
        cat "$file" >> "$merged_dir/merged-tv.m3u"
        echo "" >> "$merged_dir/merged-tv.m3u" # Leerzeile für bessere Lesbarkeit
    done

    print_success "Zusammenführung abgeschlossen: $merged_dir/merged-tv.m3u"
}

if [[ $# -ne 2 ]]; then echo "Nutzung: $0 <hd_ordner> <sd_ordner>"; exit 1; fi
main "$@"
