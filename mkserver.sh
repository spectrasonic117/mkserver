#!/bin/sh

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

    # little helpers for terminal print control and key input
    ESC=$( printf "\033")
    cursor_blink_on()  { printf "$ESC[?25h"; }
    cursor_blink_off() { printf "$ESC[?25l"; }
    cursor_to()        { printf "$ESC[$1;${2:-1}H"; }
    print_option()     { printf "   $1 "; }
    print_selected()   { printf "  $ESC[7m $1 $ESC[27m"; }
    get_cursor_row()   { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo ${ROW#*[}; }
    key_input()        { read -s -n3 key 2>/dev/null >&2
                         if [[ $key = $ESC[A ]]; then echo up;    fi
                         if [[ $key = $ESC[B ]]; then echo down;  fi
                         if [[ $key = ""     ]]; then echo enter; fi; }

    # initially print empty new lines (scroll down if at bottom of screen)
    for opt; do printf "\n"; done

    # determine current screen position for overwriting the options
    local lastrow=`get_cursor_row`
    local startrow=$(($lastrow - $#))

    # ensure cursor and input echoing back on upon a ctrl+c during read -s
    trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
    cursor_blink_off

    local selected=0
    while true; do
        # print options by overwriting the last lines
        local idx=0
        for opt; do
            cursor_to $(($startrow + $idx))
            if [ $idx -eq $selected ]; then
                print_selected "$opt"
            else
                print_option "$opt"
            fi
            ((idx++))
        done

        # user key control
        case `key_input` in
            enter) break;;
            up)    ((selected--));
                   if [ $selected -lt 0 ]; then selected=$(($# - 1)); fi;;
            down)  ((selected++));
                   if [ $selected -ge $# ]; then selected=0; fi;;
        esac
    done

    # cursor position back to normal
    cursor_to $lastrow
    printf "\n"
    cursor_blink_on

    return $selected
}

INIT_RAM="1G"
MAX_RAM="3G"

echo "$(tput setaf 2)Generando servidor de Minecraft con PaperMC"
read -p "${GREEN}Nombre del Servidor: ${RES}" FOLDER_NAME

mkdir "${FOLDER_NAME}"
cd "${FOLDER_NAME}"

# Download a purpur server file
# echo "${YELLOW}Select Version: ${RES}"
# echo
# options=("1.20.4" "1.19.4" "1.18.2" "1.17.1" "1.16.5")
# select_option "${options[@]}"
# choice=$?
# MINECRAFT_VERSION="${options[$choice]}"

echo "${YELLOW}Select Server Project: ${RES}"
echo
options=("paper" "purpur")
select_option "${options[@]}"
choice=$?
PROJECT="${options[$choice]}"
MINECRAFT_VERSION="1.20.4"

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


curl -o server.jar $JAR_DOWNLOAD
echo "${YELLOW}Server download completed${RES}"


# Create Eula File
echo "eula=true" > eula.txt
echo "${YELLOW}Archivo Eula creado.${RES}"

# Create the icon server
echo "${YELLOW}"
curl -o server-icon.png "https://raw.githubusercontent.com/spectrasonic117/Server-Assets/master/ServerAssets/nineblock_icon.png"
echo "${RES}"
echo "${GREEN}Icono Servidor creado."

clear
echo "${BOLD}${YELLOW}Configure ${BLUE}server.properties: ${RES}"

read -p "${GREEN}Max Players (Int) ${RES}" MXPLAYERS ;clear
read -p "${GREEN}View Distance (Int >5): ${RES}" VIEWDISTANCE ;clear
read -p "${GREEN}Simulation Distance (Int >5): ${RES}" SIMDISTANCE ;clear

# ------------------------------
echo "${YELLOW}Enable Command Blocks: ${RES}"
echo
options=("true" "false")
select_option "${options[@]}"
choice=$?
ENABLECB="${options[$choice]}"
clear

# ------------------------------
echo "${YELLOW}Select Gamemode: ${RES}"
echo
options=("survival" "creative" "adventure" "spectator")
select_option "${options[@]}"
choice=$?
GAMEMODE="${options[$choice]}"
clear

# ------------------------------
echo "${YELLOW}Select Difficulty: ${RES}"
echo
options=("peaceful" "easy" "normal" "hard")
select_option "${options[@]}"
choice=$?
DIFFICULTY="${options[$choice]}"
clear

# ------------------------------
echo "${YELLOW}Hardcore: ${RES}"
echo
options=("false" "true")
select_option "${options[@]}"
choice=$?
HARDCORE="${options[$choice]}"
clear

# ------------------------------
echo "${YELLOW}Spawn Monsters: ${RES}"
echo
options=("true" "false")
select_option "${options[@]}"
choice=$?
SPAWNMONSTERS="${options[$choice]}"
clear

# ------------------------------
echo "${YELLOW}Spawn NPCs: ${RES}"
echo
options=("true" "false")
select_option "${options[@]}"
choice=$?
SPAWNNPCS="${options[$choice]}"
clear

# ------------------------------
echo "${YELLOW}Spawn Animals: ${RES}"
echo
options=("true" "false")
select_option "${options[@]}"
choice=$?
SPAWNANIMALS="${options[$choice]}"
clear

# ------------------------------
echo "${YELLOW}Allow Nether: ${RES}"
echo
options=("true" "false")
select_option "${options[@]}"
choice=$?
ALLOWNETHER="${options[$choice]}"
clear

# ------------------------------
echo "${YELLOW}Allow White List: ${RES}"
echo
options=("false" "true")
select_option "${options[@]}"
choice=$?
WHITELIST="${options[$choice]}"
clear

# ------------------------------
echo "${YELLOW}Allow PVP: ${RES}"
echo
options=("true" "false")
select_option "${options[@]}"
choice=$?
PVP="${options[$choice]}"
clear

# ------------------------------
echo "${YELLOW}Allow Flight: ${RES}"
echo
options=("true" "false")
select_option "${options[@]}"
choice=$?
ALLOWFLIGHT="${options[$choice]}"
clear

# ------------------------------
echo "${YELLOW}Online Mode: ${RES}"
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
server-name=Unknown Server
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
java -Xmx${INIT_RAM} -Xms${MAX_RAM} -jar server.jar nogui" > start.sh
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

echo "$(tput bold)$(tput setaf 2)Servidor Purpur creado correctamente.${RES}"
