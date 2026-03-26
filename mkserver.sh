#!/bin/bash

# Este scrpt crea un servidor de Minecraft con la ultima build de Papermc

# === Colors ===
BLACK="$(tput setaf 0)"
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
BLUE="$(tput setaf 4)"
MAGENTA="$(tput setaf 5)"
CYAN="$(tput setaf 6)"
WHITE="$(tput setaf 7)"
RES="$(tput sgr 0)"
BOLD="$(tput bold)"
UNDERLINE="$(tput smul)"
ITALIC="$(tput sitm)"
INVERT="$(tput smso)"

BBLACK="$(tput setab 0)"
BRED="$(tput setab 1)"
BGREEN="$(tput setab 2)"
BYELLOW="$(tput setab 3)"
BBLUE="$(tput setab 4)"
BMAGENTA="$(tput setab 5)"
BCYAN="$(tput setab 6)"
BWHITE="$(tput setab 7)"
BRES="$(tput sgr 0)"

function select_option {
    # Optional prompt displayed above options (set SELECT_PROMPT before calling)
    local prompt="${SELECT_PROMPT:-}"
    local selected=0
    local options=("$@")
    local num_options=${#options[@]}

    # Ocultar cursor y configurar trap para restaurar
    tput civis
    trap 'tput cnorm; exit' INT TERM

    while true; do
        # Limpiar pantalla y mostrar opciones
        clear
        echo "${YELLOW}Use ↑/↓ para navegar, Enter para seleccionar:${RES}"
        echo
        # Show optional description if provided
        if [[ -n "$prompt" ]]; then
            echo -e "$prompt"
            echo
        fi
        for i in "${!options[@]}"; do
            if [[ $i -eq $selected ]]; then
                echo "${GREEN}▶ ${options[$i]}${RES}"
            else
                echo "  ${options[$i]}"
            fi
        done
        echo

        # Leer entrada del teclado
        read -rsn3 key 2>/dev/null

        case "$key" in
            $'\x1b[A')  # Flecha arriba
                ((selected--))
                ;;
            $'\x1b[B')  # Flecha abajo
                ((selected++))
                ;;
            "")  # Enter
                break
                ;;
        esac

        # Mantener selección dentro de límites
        if [[ $selected -lt 0 ]]; then selected=$((num_options - 1)); fi
        if [[ $selected -ge $num_options ]]; then selected=0; fi
    done

    # Restaurar cursor
    tput cnorm
    # Clear prompt for next usage
    unset SELECT_PROMPT
    return $selected
}

INIT_RAM="1G"
MAX_RAM="2G"

printf "${GREEN}
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⠛⠛⠛⠛⠛⢿⣿⣿⣿⣿⡟⠛⠛⠛⠛⠛⣿⣿⣿⣿
⣿⣿⣿⣿⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⣿⣿⣿⣿
⣿⣿⣿⣿⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⣿⣿⣿⣿
⣿⣿⣿⣿⣶⣶⣶⣶⣶⠈⠉⠉⠉⠉⠁⣶⣶⣶⣶⣶⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⡟⠛⠛⠀⠀⠀⠀⠀⠀⠛⠛⢻⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⡇⠀⠀⢰⣶⣶⣶⣶⡆⠀⠀⢸⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣇⣀⣀⣼⣿⣿⣿⣿⣇⣀⣀⣸⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿

${YELLOW}${BOLD}MkServer by Spectrasonic${RES}

"

echo "${GREEN}Generando servidor de ${MAGENTA}Minecraft con Plugins${RES}"
if [ -n "$1" ]; then
    FOLDER_NAME="$1"
    echo "${GREEN}Nombre del Servidor: ${BOLD}${FOLDER_NAME}${RES}"
else
    read -p "${GREEN}${BOLD}Nombre del Servidor: ${RES}" FOLDER_NAME
fi

	if [ -d "${FOLDER_NAME}" ]; then
	echo "${RED}El directorio ya existe${RES}"
	PROJECT="${FOLDER_NAME}"
else
	mkdir "${FOLDER_NAME}"

	# Seleccionar versión de Minecraft
  SELECT_PROMPT="${GREEN}Select Minecraft Version:${RES}"
  options=("1.20.1" "1.20.4" "1.21.1" "1.21.4" "1.21.8" "1.21.10" "1.21.11")
  select_option "${options[@]}"
  choice=$?
  MINECRAFT_VERSION="${options[$choice]}"
	clear

  # Seleccionar tipo de servidor
  SELECT_PROMPT="${GREEN}Select Server Project:${RES}"
  options=("paper" "purpur")
  select_option "${options[@]}"
  choice=$?
  PROJECT="${options[$choice]}"
	clear

	case $PROJECT in
		"paper")
			echo "${BLUE}PaperMC Selected${RES}"
			LATEST_BUILD=$(curl -s https://api.papermc.io/v2/projects/${PROJECT}/versions/${MINECRAFT_VERSION}/builds | \
			jq -r '.builds | map(select(.channel == "default") | .build) | .[-1]')
			JAR_NAME=${PROJECT}-${MINECRAFT_VERSION}-${LATEST_BUILD}.jar
			JAR_DOWNLOAD="https://api.papermc.io/v2/projects/${PROJECT}/versions/${MINECRAFT_VERSION}/builds/${LATEST_BUILD}/downloads/${JAR_NAME}"
			;;
		"purpur")
			JAR_DOWNLOAD="https://api.purpurmc.org/v2/purpur/${MINECRAFT_VERSION}/latest/download"
			;;
	esac
fi

cd "${FOLDER_NAME}"

if [ ! -f "server.jar" ]; then
	curl -o server.jar $JAR_DOWNLOAD
	echo "${YELLOW}${BOLD}Completa Descarga del Servidor JAR${RES}"
else
	echo "${BLUE}Server JAR Existente${RES}"
fi

# Create Eula File
echo "eula=true" > eula.txt
echo "${YELLOW}Archivo Eula creado.${RES}"

# Create the icon server
echo "${YELLOW}"
curl -o server-icon.png "https://raw.githubusercontent.com/spectrasonic117/Server-Assets/master/ServerAssets/nineblock_icon.png"
echo "${RES}"
echo "${GREEN}Icono Servidor creado."

# Create Directories

mkdir -p plugins
mkdir -p config

# Server Config
curl -o server.properties "https://raw.githubusercontent.com/spectrasonic117/mkserver/refs/heads/master/server_config/bukkit.yml"
curl -o pufferfish.yml "https://raw.githubusercontent.com/spectrasonic117/mkserver/refs/heads/master/server_config/pufferfish.yml"
curl -o purpur.yml "https://raw.githubusercontent.com/spectrasonic117/mkserver/refs/heads/master/server_config/purpur.yml"
curl -o spigot.yml "https://raw.githubusercontent.com/spectrasonic117/mkserver/refs/heads/master/server_config/spigot.yml"

# Paper Config

curl -o ./config/paper-global.yml "https://raw.githubusercontent.com/spectrasonic117/mkserver/refs/heads/master/server_config/config/paper-global.yml"
curl -o ./config/paper-world-defaults.yml "https://raw.githubusercontent.com/spectrasonic117/mkserver/refs/heads/master/server_config/config/paper-world-defaults.yml"

clear
echo "${BOLD}${YELLOW}Configure ${BLUE}server.properties: ${RES}"

read -p "${GREEN}Max Players (Int) ${RES}" MXPLAYERS ;clear
read -p "${GREEN}View Distance (Int >5): ${RES}" VIEWDISTANCE ;clear
read -p "${GREEN}Simulation Distance (Int >5): ${RES}" SIMDISTANCE ;clear

# ------------------------------
SELECT_PROMPT="${GREEN}Enable Command Blocks:${RES}"
options=("true" "false")
select_option "${options[@]}"
choice=$?
ENABLECB="${options[$choice]}"
clear

# ------------------------------
SELECT_PROMPT="${GREEN}Select Gamemode:${RES}"
options=("survival" "creative" "adventure" "spectator")
select_option "${options[@]}"
choice=$?
GAMEMODE="${options[$choice]}"
clear

# ------------------------------
SELECT_PROMPT="${GREEN}Select Difficulty:${RES}"
options=("peaceful" "easy" "normal" "hard")
select_option "${options[@]}"
choice=$?
DIFFICULTY="${options[$choice]}"
clear

# ------------------------------
SELECT_PROMPT="${RED}Hardcore:${RES}"
options=("false" "true")
select_option "${options[@]}"
choice=$?
HARDCORE="${options[$choice]}"
clear

# ------------------------------
SELECT_PROMPT="${GREEN}Spawn Monsters:${RES}"
options=("true" "false")
select_option "${options[@]}"
choice=$?
SPAWNMONSTERS="${options[$choice]}"
clear

# ------------------------------
SELECT_PROMPT="${GREEN}Spawn NPCs:${RES}"
options=("true" "false")
select_option "${options[@]}"
choice=$?
SPAWNNPCS="${options[$choice]}"
clear

# ------------------------------
SELECT_PROMPT="${GREEN}Spawn Animals:${RES}"
options=("true" "false")
select_option "${options[@]}"
choice=$?
SPAWNANIMALS="${options[$choice]}"
clear

# ------------------------------
SELECT_PROMPT="${GREEN}Allow Nether:${RES}"
options=("true" "false")
select_option "${options[@]}"
choice=$?
ALLOWNETHER="${options[$choice]}"
clear

# ------------------------------
SELECT_PROMPT="${GREEN}Allow Whitelist: ${RES}"
options=("false" "true")
select_option "${options[@]}"
choice=$?
WHITELIST="${options[$choice]}"
clear

# ------------------------------
SELECT_PROMPT="${GREEN}Allow PVP: ${RES}"
options=("true" "false")
select_option "${options[@]}"
choice=$?
PVP="${options[$choice]}"
clear

# ------------------------------
SELECT_PROMPT="${GREEN}Allow Flight: ${RES}"
options=("true" "false")
select_option "${options[@]}"
choice=$?
ALLOWFLIGHT="${options[$choice]}"
clear

# ------------------------------
SELECT_PROMPT="${GREEN}Online Mode: ${RES}"
echo
options=("true" "false")
select_option "${options[@]}"
choice=$?
ONLINEMODE="${options[$choice]}"
clear

# ------------------------------
read -p "${GREEN}MOTD: ${RES}" MOTD ; clear

printf "enable-jmx-monitoring=false
rcon.port=25575
level-seed=
gamemode=${GAMEMODE}
enable-command-block=${ENABLECB}
enable-query=false
generator-settings={}
enforce-secure-profile=false
level-name=world
motd=${MOTD}
query.port=25565
pvp=${PVP}
generate-structures=true
max-chained-neighbor-updates=1000000
difficulty=${DIFFICULTY}
network-compression-threshold=256
max-tick-time=60000
require-resource-pack=true
use-native-transport=true
max-players=${MXPLAYERS}
online-mode=${ONLINEMODE}
enable-status=true
allow-flight=${ALLOWFLIGHT}
initial-disabled-packs=
broadcast-rcon-to-ops=true
view-distance=${VIEWDISTANCE}
server-ip=
resource-pack-prompt=
allow-nether=${ALLOWNETHER}
server-port=25565
enable-rcon=true
sync-chunk-writes=false
server-NineBlock Server
op-permission-level=4
prevent-proxy-connections=false
hide-online-players=false
resource-pack=
entity-broadcast-range-percentage=100
simulation-distance=${SIMDISTANCE}
rcon.password=537543fjm.
player-idle-timeout=0
debug=false
force-gamemode=false
rate-limit=0
hardcore=${HARDCORE}
white-list=${WHITELIST}
broadcast-console-to-ops=true
spawn-npcs=${SPAWNNPCS}
spawn-animals=${SPAWNANIMALS}
log-ips=false
function-permission-level=2
initial-enabled-packs=vanilla
level-type=minecraft\:normal
text-filtering-config=
spawn-monsters=${SPAWNMONSTERS}
enforce-whitelist=false
spawn-protection=0
resource-pack-sha1=
max-world-size=29999984" > $PWD/server.properties

# Crete a start.sh File
printf "#!/usr/bin/env sh
java -Xms${INIT_RAM} -Xmx${MAX_RAM} -jar server.jar nogui" > start.sh
chmod +x start.sh
chmod +x server.jar

while true; do
	printf "${BLUE}Run ${PROJECT} ${MINECRAFT_VERSION} Server?: ${YELLOW}(Y/N)${RES} "
    read yn
    case $yn in
        [Yy]* )
        command bash start.sh
        break;;
        [Nn]* )
        exit 0
        ;;
        * )
        echo "Please answer yes or no."
        ;;
    esac
done

echo "${BOLD}${GREEN}Servidor ${YELLOW}${PROJECT} ${GREEN}creado correctamente.${RES}"
