rm -rf orange-web-terminal
mkdir orange-web-terminal
cd orange-web-terminal

cat << 'EOF' > install.sh
#!/bin/bash

# 0. Проверка на root
if [ "$EUID" -ne 0 ]; then 
  echo "❌ Ошибка: Скрипт нужно запускать от имени root (sudo ./install.sh)"
  exit 1
fi

echo "🚀 Установка веб-терминала ttyd + tmux на порт 80..."

# 1. Обновляем пакеты и ставим зависимости
apt update
apt install tmux wget -y

# 2. Пытаемся установить ttyd через apt
apt install ttyd -y

if ! command -v ttyd &> /dev/null; then
    echo "⚠️ Пакета ttyd нет в apt. Скачиваем готовый бинарник с GitHub..."
    
    # Устанавливаем возможные зависимости для бинарника
    apt install libjson-c5 libwebsockets17 -y 2>/dev/null || apt install libjson-c4 libwebsockets16 -y 2>/dev/null
    
    # Определяем архитектуру процессора
    ARCH=$(uname -m)
    if [ "$ARCH" = "aarch64" ]; then
        TTYD_BINARY="ttyd.aarch64"
    elif [ "$ARCH" = "armv7l" ] || [ "$ARCH" = "armhf" ]; then
        TTYD_BINARY="ttyd.armhf"
    else
        TTYD_BINARY="ttyd.arm"
    fi
    
    echo "Архитектура: $ARCH. Качаем $TTYD_BINARY..."
    
    # Скачиваем последнюю версию
    wget -O /usr/bin/ttyd "https://github.com/tsl0922/ttyd/releases/latest/download/$TTYD_BINARY"
    
    # Делаем исполняемым
    chmod +x /usr/bin/ttyd
    
    if ! command -v ttyd &> /dev/null; then
        echo "❌ Не удалось скачать ttyd."
        exit 1
    fi
    echo "✅ ttyd успешно установлен."
fi

# 3. Создаем systemd сервис (ПОРТ 80)
cat << 'SERVICE' > /etc/systemd/system/ttyd.service
[Unit]
Description=ttyd Web Terminal with tmux
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/ttyd -p 80 -c admin:1234 -W tmux new -A -s orangeshell
Restart=always
User=root

[Install]
WantedBy=multi-user.target
SERVICE

# 4. Перезагружаем и запускаем
systemctl daemon-reload
systemctl enable ttyd
systemctl restart ttyd

# 5. Выводим результат
IP_ADDR=$(hostname -I | awk '{print $1}')
echo ""
echo "✅ Готово!"
echo "🌐 Открой в браузере: http://$IP_ADDR"
echo "🔑 Логин: admin | Пароль: 1234"
echo ""
EOF

chmod +x install.sh

# Запуск установки
sudo ./install.sh
