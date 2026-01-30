#!/bin/sh

notify() {
    command -v notify-send >/dev/null && notify-send -a "Screenshot" "Screenshot" "$1" -i camera -t 4000
}

# === 1. Select mode ===
type_choice=$(printf '%s\n' "select area" "full screen" "active window" | fuzzel -w 16 -l 4 -d --prompt="screenshot")
[ -z "$type_choice" ] && exit 0

# === 2. Select copy to clipboard or save to file ===
action=$(printf '%s\n' "save to file" "copy to clipboard" | fuzzel -w 18 -l 3 -d --prompt="screenshot")
[ -z "$action" ] && exit 0

case "$action" in
    "save to file")      save_mode="file" ;;
    "copy to clipboard") save_mode="clipboard" ;;
    *) exit 1 ;;
esac

# === 3. Choose delay ===
choose_delay=$(printf '%s\n' "now" "5s" "10s" | fuzzel -w 16 -l 4 -d --prompt="choose delay")
[ -z "$choose_delay" ] && exit 0

case "$choose_delay" in
    "now") delay=0 ;;
    "5s")  delay=5 ;;
    "10s") delay=10 ;;
    *)     exit 0 ;;
esac

# === 4. Get active window geometry ===
geometry=""
case "$type_choice" in
    "select area")
        geometry=$(slurp -b 00000000 -c 1c71d8ff -s 1c71d811 -w 1)
        [ -z "$geometry" ] && { notify "\narea not selected"; exit 1; }
	;;
    "active window")
        if ! command -v jq >/dev/null; then
            notify "\njq not found"
            exit 1
        fi
        geometry=$(swaymsg -t get_tree | jq -r '.. | select(.focused? and .type == "con" and (.pid or .app_id)) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' 2>/dev/null)
        if [ -z "$geometry" ] || echo "$geometry" | grep -q null; then
            notify "\nactive window not found"
            exit 1
        fi
        ;;
    "full screen")
        ;;
    *)
        exit 1
        ;;
esac

# === 5. Start timer ===
if [ "$delay" -gt 0 ]; then
    notify "\nin ${delay}s ..."
    sleep "$delay"
fi

# === 6. Screenshot ===
if [ "$save_mode" = "clipboard" ]; then
    # copy to clipboard
    if [ -n "$geometry" ]; then
        grim -g "$geometry" - | wl-copy
    else
        grim - | wl-copy
    fi
    notify "\ncopied to clipboard"

else
    # save to file
    outdir="${XDG_PICTURES_DIR:-$HOME/Pictures}"
    mkdir -p "$outdir"
    outfile="$outdir/screenshot_$(date +'%Y-%m-%d-%H%M%S').png"
    if [ -n "$geometry" ]; then
        grim -g "$geometry" "$outfile"
    else
        grim "$outfile"
    fi
    notify "\nsaved: $(basename "$outfile")"
fi
