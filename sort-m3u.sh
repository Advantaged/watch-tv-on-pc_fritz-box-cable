#!/bin/bash

# sort-m3u.sh (Optimierte Version für FritzBox & Standard-IPTV)

# Überprüfung, ob Eingabedateien angegeben wurden
if [ $# -eq 0 ]; then
    echo "Fehler: Keine Eingabedateien angegeben"
    echo "Nutzung: $0 datei1.m3u datei2.m3u ..."
    exit 1
fi

# Jede angegebene Datei verarbeiten
for input_arg in "$@"; do
    echo "Verarbeitung läuft: $input_arg"

    if [[ -f "$input_arg" ]]; then
        input_file="$input_arg"
    elif [[ -f "$input_arg.m3u" ]]; then
        input_file="$input_arg.m3u"
    else
        echo "Fehler: Datei '$input_arg' nicht gefunden"
        continue
    fi

    # Zeitstempel und Ordnerstruktur erstellen
    timestamp=$(date '+%Y-%m-%d_%H-%M-%S')
    base_name=$(basename "$input_file" .m3u)
    output_dir="${timestamp}_${base_name}"
    titles_dir="${output_dir}/titles"

    mkdir -p "$output_dir" "$titles_dir"

    log_file="${output_dir}/processing.log"
    sorted_file="${output_dir}/sorted_${base_name}.m3u"

    {
        echo "M3U Channel Sorting Log - $(date)"
        echo "Input: $input_file"
        echo "========================================"
    } > "$log_file"

    # Header-Prüfung
    first_line=$(head -n1 "$input_file")
    if [[ "$first_line" != "#EXTM3U" ]]; then
        echo "Info: Fehlender #EXTM3U Header wird ergänzt." >> "$log_file"
    fi

    echo "Extrahiere Sender..." | tee -a "$log_file"
    channel_count=0
    line_number=0

    # Hauptschleife zur Verarbeitung der Kanäle
    while IFS= read -r line || [ -n "$line" ]; do
        line_number=$((line_number + 1))

        # Suche nach Sender-Info Zeile[cite: 1, 4]
        if [[ "$line" =~ ^#EXTINF: ]]; then
            channel_name=$(echo "$line" | sed 's/.*,//')
            # Dateinamen-sicher machen
            safe_filename=$(echo "$channel_name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-zA-Z0-9._-]/_/g')

            # Nächste Zeile lesen (könnte Option oder URL sein)
            if IFS= read -r next_line; then
                line_number=$((line_number + 1))

                # FALL A: Zeile ist eine Option (typisch für FritzBox)[cite: 4]
                if [[ "$next_line" =~ ^#EXTVLCOPT: ]]; then
                    if IFS= read -r url_line; then
                        line_number=$((line_number + 1))
                        channel_content="$line"$'\n'"$next_line"$'\n'"$url_line"
                    fi
                # FALL B: Zeile ist direkt die URL (einfache IPTV-Liste)[cite: 1]
                else
                    channel_content="$line"$'\n'"$next_line"
                fi

                # Einzelne Sender-Datei für die spätere Sortierung speichern
                channel_file="${titles_dir}/${safe_filename}.channel"
                echo "$channel_content" > "$channel_file"
                channel_count=$((channel_count + 1))
            fi
        fi
    done < "$input_file"

    if [ $channel_count -eq 0 ]; then
        echo "Fehler: Keine validen Kanäle gefunden." | tee -a "$log_file"
        continue
    fi

    # Sortierung und Zusammenbau der neuen M3U-Datei[cite: 3]
    echo "Sortierung wird durchgeführt..." | tee -a "$log_file"
    echo "#EXTM3U" > "$sorted_file"

    # Kanäle alphabetisch sortiert hinzufügen
    find "$titles_dir" -name "*.channel" -type f | sort -f | while read -r channel_file; do
        cat "$channel_file" >> "$sorted_file"
    done

    echo "Abgeschlossen: $channel_count Sender in $sorted_file gespeichert." | tee -a "$log_file"
    echo "---"
done

echo "Alle Dateien wurden erfolgreich verarbeitet!"
