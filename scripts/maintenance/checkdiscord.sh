#!/bin/sh
# Ubuntu24.04 にて開発検証
sudo apt autoremove -y discord --purge
wget https://discord.com/api/download/stable\?platform\=linux\&format\=deb -O /tmp/discord-update.deb
sudo apt install -y /tmp/discord-update.deb
