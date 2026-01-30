#!/bin/bash

# Получаем URL из dunst
url="$1"

# Браузер и рабочее место
BROWSER="firefox"  # или "chromium", "qutebrowser" и т.д.
WORKSPACE="1"     # рабочее место, где должен быть браузер

# Открываем ссылку в браузере на нужном рабочем месте
# Если браузер уже запущен — он перейдёт на него, иначе запустится
swaymsg "[app_id=$BROWSER] focus" || {
    # Если браузер не найден, запускаем его на нужном WS
    swaymsg workspace $WORKSPACE
    $BROWSER "$url" &
}

# Явно фокусируемся на окне браузера
sleep 0.5
swaymsg "[app_id=$BROWSER] focus"

# Дополнительно: переключаемся на рабочее место
swaymsg workspace $WORKSPACE
