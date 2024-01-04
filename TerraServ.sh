#!/bin/bash

# Demander des informations à l'utilisateur
read -p "Version du serveur Terraria (ex: 1.4.4.9): " terraria_version
read -p "Nom du monde: " world_name
read -p "Nombre de joueurs max: " max_players
read -p "Difficulté (0-3): " difficulty

# Installation de Docker
sudo apt update
sudo apt install -y wget unzip screen docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Créer un dossier pour le projet Terraria
mkdir -p ~/terraria-server
cd ~/terraria-server

# Création du Dockerfile
cat <<EOF > Dockerfile
FROM debian:latest

RUN apt-get update && apt-get install -y wget unzip screen

RUN wget https://terraria.org/api/download/pc-dedicated-server/terraria-server-${terraria_version//./}.zip -O terraria-server.zip
RUN unzip terraria-server.zip -d /terraria
RUN chmod +x /terraria/${terraria_version//./}/Linux/TerrariaServer.bin.x86_64

COPY serverconfig.txt /terraria/${terraria_version//./}/Linux/serverconfig.txt

EXPOSE 7777

WORKDIR /terraria/${terraria_version//./}/Linux

CMD ["./TerrariaServer.bin.x86_64", "-config", "serverconfig.txt"]
EOF

# Création du fichier de configuration
cat <<EOF > serverconfig.txt
world=/terraria/MyWorld.wld
maxplayers=$max_players
port=7777
autocreate=3
worldname=$world_name
difficulty=$difficulty
EOF

# Construction de l'image Docker
docker build -t terraria-server:${terraria_version//./} .

# Démarrer le conteneur avec redémarrage automatique
docker run -d -p 7777:7777 --restart=always --name mon-serveur-terraria terraria-server:${terraria_version//./}
