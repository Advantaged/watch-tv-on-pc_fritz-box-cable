
# watch-tv-on-pc_fritz-box-cable
## Instructions.md
### Notes:
* These instruction are designed for everybody, from newbie to pro.
* The provided scripts (`.sh`) can be always used, the provided `.m3u` can/must be replaced & the `.txt` are download-links for the `.m3u`-s.
* A log-file will be produced in any case if using `sort-all-lists.sh`.
* The original channel-lists from you modem/DFB-C_Tuner may vary.
* It's not difficult if knowing the process-es, be just patient.
* These instructions are valid for BSD, Linux & MAC-OS. If you still use Win… start you computer from a "Live-Linux.iso" like CachyOS 😉 or…

### User("special")-case Windows
* **Native Windows (CMD/PowerShell)**: ❌ No — Unix shell scripts don’t run natively.
* **Solutions**:
  * **WSL (Windows Subsystem for Linux)**: ✅ Fully supported — install WSL2, then run the script in a Linux environment.
  * **Cygwin/MSYS2**: ✅ Possible — provides Unix-like environment with Bash.
  * **Git Bash**: ✅ Can run simple scripts — suitable for basic automation. 

### Target-s:
1. Enable Live TV in FRITZ!Box
2. Generate the Channel List
3. Watch TV in VLC (how to).
4. (Optional) Use Kaffeine from KDE/Plasma to watch TV, (how to).
5. Sorting channels alphabetically

Your FRITZ!Box 6591 Cable has a built-in (four (4) channels) DVB-C tuner and can stream live TV over your network. Since you already have VLC &|| Kaffeine on Linux, follow these steps:

### 1. Enable Live TV in FRITZ!Box

* Open `http://fritz.box` or `http://192.168.178.1` in your browser.
* Go to **DVB-C > Live TV**.
* Click **"Enable Live TV"** and confirm the restart.

### 2. Generate the Channel List

* After reboot, go to **DVB-C > Channel List**.
* Click "Start Channel Search" to scan for available channels.
* Once done, go to "Channel List" tab and click **"Generate Channel List"**.
* Download the `.m3u` file (e.g., `tvhd.m3u`) to your operating-system/data-carrier.

### 3. Watch TV in VLC

* Install VLC with `sudo pacman -S --needed --noconfirm vlc`, for this you need to open your CLI/Terminal/`konsole`.
* Open VLC.
* Drag and drop the downloaded/sorted `.m3u` file into VLC.
* VLC will play the first channel; use **View > Playlist** to switch between channels.

### 4. (Optional) Use Kaffeine (KDE/Plasma)

* Install Kaffeine with `sudo pacman -S --needed --noconfirm kaffeine`, for this you need to open your CLI/Terminal/`konsole`.
* Open Kaffeine.
* Go to **File > Open Network Stream**.
* Enter the stream URL: `http://fritz.box:49000/dvbc.m3u` or use the downloaded and/or (&||) sorted `.m3u` file-s.
* Kaffeine will read the playlist and allow channel selection.
> 🔔 Note: The FRITZ!Box acts as a DVB-C server (SAT>IP). Up to four different channels can be streamed simultaneously to different devices.

### 5. Sorting channels alphabetically

The FRITZ!Box 6591 Cable does not support alphabetical sorting of channels directly in its channel list. The order is typically based on frequency or channel number.

To sort channels alphabetically:

* 1. In **VLC**:
  * After loading the `.m3u` file, go to **View > Playlist**. Right-click inside the playlist, then select **Sort > Title** to arrange channels alphabetically.
* 2. In **Kaffeine**:
  * Use the playlist view and manually reorder entries, or edit the `.m3u` file externally with a text editor to sort entries by name.

You can edit the `.m3u` file using a script or text editor to reorder channels alphabetically before loading it into your media player.

**The easiest and most reliable method** is to use a simple script to sort the `.m3u` file alphabetically by channel name.

### Notes:
1. The original `.m3u` file/list are named by your Fritz-Box.
2. At this point you can download `watch-tv-on-pc_fritz-box-cable` if not yet done from here.
3. Copy your original `.m3u` file/list inside `watch-tv-on-pc_fritz-box-cable`🟰replace maybe obsolete `.m3u`-s.
* If you are in hurry &|| want avoid some "additional" manual work… 👇

### Time saving method:
* For following steps you need to open your CLI/Terminal/`konsole` & navigate to `watch-tv-on-pc_fritz-box-cable` folder.
1. Make `sort-all-lists.sh` executable with command: `chmod +x sort-all-lists.sh` &…
2. RUN `./sort-all-lists.sh`
* This will execute the three scripts leaving your original & copied (`.m3u`) file/lists unchanged/untouched.
* At this point you can use already the sorted lists in `vlc` &|| `kaffeine` like in **§ 3.** & **4.** explained.
* FYI here the `sort-all-lists.sh` script:
```
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

```

### 6. The manual mode, FYI
* ✅ **Recommended: One-liner Bash Script**
Since each channel entry has three lines:
* 1. `#EXTINF:0,Channel Name`.
* 2. `#EXTVLCOPT:network-caching=1000`.
* 3. `rtsp://...` channel-address.
* **FYI here as example the** `sort-radio-list.sh` **script**. All scripts are already present.
```
#!/bin/bash
#sort-radio-list.sh
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
}' radio.m3u > sorted_radio.m3u

# Add header
sed -i '1i#EXTM3U' sorted_radio.m3u
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
}' radio.m3u > sorted_radio.m3u

# Add Header
sed -i '1i#EXTM3U' sorted_radio.m3u


```
This:

* Splits entries at #EXTINF:
* Extracts the channel name (after comma) for sorting
* Sorts case-insensitively (-f)
* Reconstructs the full three-line entries &
* Then add/check the header: `sed -i '1i#EXTM3U' sorted_radio.m3u`.

Now your playlist is alphabetically sorted and fully functional.❗️

Replace `radio.m3u` with `tvhd.m3u` or `tvsd.m3u` as needed in the other two scripts.

### Automate It
Save the script as `sort-radio-list.sh`, make it executable (`chmod +x sort-radio-list.sh`), and run (`./sort-radio-list.sh`) whenever you download a new `.m3u` from http://fritz.box/dvb/m3u/. Repeat the procedure for `sort-tvhd-list.sh` & `sort-tvsd-list.sh`.

✅  **Done** 👍 **& Enjoy**❗️
