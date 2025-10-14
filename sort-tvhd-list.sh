#!/bin/bash
# sort-tvhd-list.sh
# Read entire file, group every 3 lines, sort by channel name
awk '
/^#EXTINF:/ {
    if (current) print current | "sort -f"
    current = $0; next
}
/^#EXTVLCOPT:/ {
    current = current "\n" $0; next
}
/^rtsp:/ {
    current = current "\n" $0
}
END {
    if (current) print current | "sort -f"
    close("sort -f")
}' tvhd.m3u > sorted_tvhd.m3u

# Add header
sed -i '1i#EXTM3U' sorted_tvhd.m3u
#!/bin/bash
awk '
BEGIN {
    RS = "\n#EXTINF:"; ORS = "";
    first = 1
}
{
    if (first) {
        first = 0
    } else {
        gsub(/^\n/, "")
    }
    match($0, /[^,]*,(.*)\n/, arr)
    name = tolower(arr[1])
    entry[name] = entry[name] "#EXTINF:" $0 "\n"
}
END {
    n = asorti(entry, sorted)
    for (i = 1; i <= n; i++) {
        printf "%s", entry[sorted[i]]
    }
}' tvhd.m3u > sorted_tvhd.m3u

# Add Header
sed -i '1i#EXTM3U' sorted_tvhd.m3u
