# watch-tv-on-pc_fritz-box-cable
## Instructions.md

* **Merit to:** [DeepSeek](https://chat.deepseek.com/)

### Notes:
* These instruction & software (script) are designed for everybody, from newbie to pro.
* Don't be scared from long text/explanation, finally is just a question of downloading the script, activate & use it as described.
* The provided executable (`sort-m3u.sh`) is tested on CachyOS.
* Sources-backup in timestamped folder (`2025-10-12_12-34-57_source-lists`).
* Download-links in timestamped folder (`2025-10-12_12-34-57_download-links`).
* Sorted-Channels-lists also included in timestamped-folders (`2025-10-15_07-18-14_radio`, `2025-10-15_07-18-15_tvhd` & `2025-10-15_07-18-15_tvsd`) for local people just want copy/paste the sorted playlists.
* The original channel-lists from you modem/DFB-C_Tuner may vary.
* These instructions & software are valid for **BSD**, **Linux** & **MAC-OS**. If you still use Win… start you computer from a **"Live-Linux.iso"** with web-browser on it like **CachyOS** 😉 or a Linux-Distro on **Ventoy** or… 👇

### User("special")-case Windows
* **Native Windows (CMD/PowerShell)**: ❌ No — Unix shell scripts don’t run natively.
* **Solutions**:
  * **WSL (Windows Subsystem for Linux)**: ✅ Fully supported — install WSL2, then run the script in a Linux environment.
  * **Cygwin/MSYS2**: ✅ Possible — provides Unix-like environment with Bash.
  * **Git Bash**: ✅ Can run simple scripts — suitable for basic automation. 

### Target-s:
1. Enable Live TV in FRITZ!Box °reboot the "box".
2. Generate & Download the Channel Lists.
3. Sorting channels alphabetically with this script.
4. Watch TV in VLC (how to).
5. Use (optionally) Kaffeine from KDE/Plasma to watch TV, (how to).

### Fritz.Box Cable feature:
* Your FRITZ!Box 6591 Cable has a built-in (four (4) channels) DVB-C tuner and can stream live TV over your network.
> 🔔 Note: The FRITZ!Box acts as a DVB-C server (SAT>IP). Up to four different channels can be streamed simultaneously to different devices.
* Since VLC is a common software for every OS & Kaffeine the same for at least BSD & Linux, we can use SFF-PC (small-form-factor-pc) to enjoy TV in a Linux environment giving youtube without advertisements & all other social medias o.o.t.b...

### 1. Enable Live TV in FRITZ!Box

* Access/Open `http://fritz.box` or `http://192.168.178.1` in your browser.
* Go to **DVB-C > Live TV**.
* Click **"Enable Live TV"** and confirm the restart of Fritz.Box.

### 2. Generate the Channel List

* After reboot of Fritz.Box, access it again, go to **DVB-C > Channel List**.
* Click "Start Channel Search" to scan for available channels.
* Once done, go to "Channel List" tab and click **"Generate Channel List"**.
* Download the `.m3u` file (e.g., `radio.m3u`, `tvhd.m3u` & `tvsd.m3u`) to your operating-system/data-carrier.

### 3. Sorting channels alphabetically

The FRITZ!Box 6591 Cable does not support alphabetical sorting of channels directly in its channel list. The order is typically based on frequency or channel number.

To sort channels alphabetically:

1. In **VLC**:
* Install VLC over the terminal/CLI: `sudo pacman -S --needed --noconfirm vlc`
* After loading the `.m3u` file in VLC, go to **View > Playlist**. Right-click inside the playlist, then select **Sort > Title** to arrange channels alphabetically.
2. In **Kaffeine**:
* Install Kaffeine over terminal/CLI: `sudo pacman -S --needed --noconfirm kaffeine`
* Use the playlist view and manually reorder entries, or edit the `.m3u` file externally with a text editor to sort entries by name.

You can edit the `.m3u` file using a script or text editor (e.g. `kate`) to reorder channels alphabetically before loading it into your media player.

**The easiest and most reliable method** is to use a shell-script to sort the `.m3u` file alphabetically by channel name.

### Notes:
1. The original `.m3u` file/list are named by your Fritz-Box at the download.
2. At this point you can download `watch-tv-on-pc_fritz-box-cable` if not yet done.
3. Copy your original `.m3u` file/list inside `watch-tv-on-pc_fritz-box-cable`🟰replace maybe or backup first obsolete `.m3u`-s.

* For following steps you need to open your CLI/Terminal/`konsole` & navigate to downloaded `watch-tv-on-pc_fritz-box-cable` folder.

### Activate & use the script

1. Make `sort-m3u.sh` executable (activate) with command: `chmod +x sort-m3u.sh` &…
2. RUN e.g.: `./sort-m3u.sh radio tvhd tvsd` (all three list at one shot), ✅  **Done**❗️ 
* This will sort all three list at ones leaving untouched the original.
* The output/result are in new created timestamped-folders.
* Detailed Log-Files in timestamped-folders too.

### Usage Examples:

```
# Multiple files with extensions
./sort-m3u.sh radio.m3u tvhd.m3u tvsd.m3u

# Multiple files without extensions (script will add .m3u)
./sort-m3u.sh radio tvhd tvsd

# Mix of both
./sort-m3u.sh radio tvhd.m3u music

# Single file (still works)
./sort-m3u.sh radio
```

### Output Structure:

```
2024-01-15_14-30-25_radio/
├── titles/
├── sorted_radio.m3u
└── processing.log

2024-01-15_14-30-26_tvhd/
├── titles/
├── sorted_tvhd.m3u
└── processing.log

2024-01-15_14-30-27_tvsd/
├── titles/
├── sorted_tvsd.m3u
└── processing.log
```

### Terminal (CLI) feedback:

```
./sort-m3u.sh radio tvhd tvsd                       
Processing: radio
Processing channels...
Sorting channels...
Completed: radio.m3u -> 2025-10-15_07-18-14_radio/sorted_radio.m3u (107 channels)
---
Processing: tvhd
Processing channels...
Sorting channels...
Completed: tvhd.m3u -> 2025-10-15_07-18-15_tvhd/sorted_tvhd.m3u (31 channels)
---
Processing: tvsd
Processing channels...
Sorting channels...
Completed: tvsd.m3u -> 2025-10-15_07-18-15_tvsd/sorted_tvsd.m3u (64 channels)
---
All files processed!
```

* At this point you can use already the sorted lists in `vlc` &|| `kaffeine` like in following **§ 4.** & **§ 5.** explained.

### Automate It

* Whenever you want download new `.m3u`-s from http://fritz.box/dvb/m3u/, backup the old in timestamped folder or overwrite the old original list with the new-s or delete the old source-list. When the new playlists are downloaded, just execute again `./sort-m3u.sh radio tvhd tvsd` to get them all sorted & stored in timestamped folder.

### 4. Watch TV in VLC

* Install VLC with `sudo pacman -S --needed --noconfirm vlc`, for this you need to open your CLI/Terminal/`konsole`.
* Further information, tricks, settings & troubleshooting in additional linked file [Using M3U Channel Lists in VLC and Kaffeine](Using-M3U-Channel-Lists-in-VLC-and-Kaffeine.md).

### 5. Use (optionally) Kaffeine (KDE/Plasma)

* Install Kaffeine with `sudo pacman -S --needed --noconfirm kaffeine`, for this you need to open your CLI/Terminal/`konsole`.
* Further information, tricks, settings & troubleshooting in additional linked file [Using M3U Channel Lists in VLC and Kaffeine](Using-M3U-Channel-Lists-in-VLC-and-Kaffeine.md).


✅  **Done** 👍 **& Enjoy**❗️
