mkdir orange-web-terminal
cd orange-web-terminal

# Создаем файл автоматической установки
cat << 'EOF' > install.sh
#!/bin/bash
echo "🚀 Установка веб-терминала ttyd + tmux..."

# 1. Обновляем пакеты и устанавливаем зависимости
apt update
apt install tmux ttyd -y

# 2. Создаем systemd сервис
cat << 'SERVICE' > /etc/systemd/system/ttyd.service
[Unit]
Description=ttyd Web Terminal with tmux session persistence
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/ttyd -p 80 -c admin:1234 -W tmux new -A -s orangeshell
Restart=always
User=root

[Install]
WantedBy=multi-user.target
SERVICE

# 3. Перезагружаем systemd и запускаем сервис
systemctl daemon-reload
systemctl enable ttyd
systemctl restart ttyd

# 4. Получаем IP-адрес для удобства
IP_ADDR=$(hostname -I | awk '{print $1}')
echo "✅ Готово! Открой в браузере: http://$IP_ADDR"
echo "🔑 Логин: admin | Пароль: 1234 (измени в /etc/systemd/system/ttyd.service)"
EOF

chmod +x install.sh

# Создаем файл с инструкцией
cat << 'EOF' > README.md
# 🍊 Orange Pi Web Terminal (ttyd + tmux)

Легковесное решение для доступа к консоли Orange Pi (или любого Linux) через браузер телефона или компьютера. 

**Главная фишка:** Сессия **не сбрасывается** при обновлении страницы или разрыве соединения, благодаря интеграции с `tmux`.

## 🚀 Быстрая установка

Просто скачай и запусти скрипт от имени root:

```bash
wget https://raw.githubusercontent.com/ТВОЙ_НИК/ТВОЙ_РЕПОЗИТОРИЙ/main/install.sh
chmod +x install.sh
sudo ./install.sh
