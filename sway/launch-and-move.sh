#!/bin/bash

# Запускаем приложение в фоне
"$1" &

APP_PATTERN="$2"   # регулярное выражение для app_id
TARGET_WS="$3"

# Ждём появления окна (до 10 секунд)
for i in {1..300}; do
    WINDOW_ID=$(swaymsg -t get_tree | jq -r --arg pattern "^$APP_PATTERN" '
        .. | select(.app_id?) |
        select(.app_id | test($pattern)) |
        .id | select(.)' | head -n1)

    if [ -n "$WINDOW_ID" ]; then
        swaymsg "[con_id=$WINDOW_ID] move container to workspace $TARGET_WS" 2>/dev/null && break
    fi
    sleep 0.1
done
