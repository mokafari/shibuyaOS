#!/bin/bash

# Stoppa skriptet om något kommando misslyckas
set -e

echo "=== Startar Shibuya OS byggprocess (med mediepaket för streaming) ==="

# Konfigurationsvariabler
RPI_IMAGE_GEN_DIR_NAME="rpi-image-gen" # Namnet på katalogen för rpi-image-gen
CONFIG_SUBDIR_NAME="shibuyaos-vm-build-config" # Underkatalog för vår config-fil, relativt till $VM_HOME_DIR
CONFIG_FILE_NAME="shibuya_config_streaming_base.config" # Namn på config-filen

VM_HOME_DIR=$(eval echo "~$(whoami)") # Hämta hemkatalogen för nuvarande användare
RPI_IMAGE_GEN_FULL_PATH="$VM_HOME_DIR/$RPI_IMAGE_GEN_DIR_NAME"
CONFIG_DIR_FULL_PATH="$VM_HOME_DIR/$CONFIG_SUBDIR_NAME"
CONFIG_FILE_FULL_PATH="$CONFIG_DIR_FULL_PATH/$CONFIG_FILE_NAME"

# Gå till hemkatalogen
cd "$VM_HOME_DIR"
echo "Arbetskatalog: $(pwd)"

# 1. Klona rpi-image-gen repositoryt eller uppdatera om det redan finns
if [ ! -d "$RPI_IMAGE_GEN_FULL_PATH" ]; then
    echo "Klona rpi-image-gen till $RPI_IMAGE_GEN_FULL_PATH..."
    git clone https://github.com/raspberrypi/rpi-image-gen.git "$RPI_IMAGE_GEN_DIR_NAME"
else
    echo "$RPI_IMAGE_GEN_FULL_PATH finns redan."
    echo "Uppdaterar $RPI_IMAGE_GEN_FULL_PATH från fjärr-repo med git pull..."
    cd "$RPI_IMAGE_GEN_FULL_PATH"
    git pull
    cd "$VM_HOME_DIR" # Gå tillbaka till hemkatalogen där skriptet förväntar sig vara
fi

# 2. Gå in i den klonade/uppdaterade katalogen
cd "$RPI_IMAGE_GEN_FULL_PATH"
echo "Arbetskatalog: $(pwd)"

# 3. Installera byggberoenden (kommer att be om lösenord)
echo "Installerar byggberoenden (sudo krävs)..."
# Enkel kontroll för att undvika att köra i onödan om några nyckelpaket finns.
if ! dpkg -s coreutils &> /dev/null || ! dpkg -s quilt &> /dev/null || ! dpkg -s parted &> /dev/null; then
    sudo ./install_deps.sh
else
    echo "Några grundläggande beroenden verkar redan installerade, hoppas install_deps.sh har körts tidigare."
    echo "Om bygget misslyckas, kör 'sudo ./install_deps.sh' manuellt inuti $RPI_IMAGE_GEN_FULL_PATH."
fi

# 4. Skapa konfigurationskatalogen (utanför rpi-image-gen) om den inte finns
if [ ! -d "$CONFIG_DIR_FULL_PATH" ]; then
    echo "Skapar katalog $CONFIG_DIR_FULL_PATH..."
    mkdir -p "$CONFIG_DIR_FULL_PATH" # -p skapar föräldrakataloger om de inte finns
else
    echo "$CONFIG_DIR_FULL_PATH finns redan."
fi

# 5. Skapa konfigurationsfilen i den specificerade katalogen
echo "Skapar konfigurationsfilen $CONFIG_FILE_FULL_PATH..."
cat > "$CONFIG_FILE_FULL_PATH" << EOF
IMG_NAME='ShibuyaOS-CM4-dev-StreamingBase'
TARGET_ARCHITECTURE='arm64'
TARGET_RELEASE='bookworm'

# Default user
FIRST_USER_NAME='shibuya'
FIRST_USER_PASS='shibuya' # Kom ihåg att ändra detta för en produktionsmiljö!

# Grundläggande paket + mediepaket
PACKAGES="git ssh python3 python3-pip alsa-utils network-manager sudo ffmpeg pipewire wireplumber build-essential cmake"

# Enable SSH by default
ENABLE_SSH=1

# Set timezone
TIMEZONE='Europe/Stockholm'

# Set locale
LOCALE_DEFAULT='sv_SE.UTF-8'

# Hostname
TARGET_HOSTNAME='shibuya-cyberdeck'

# Systempaket som ska installeras utöver de som definieras i PACKAGES
# firmware-brcm80211 för Wi-Fi/BT på CM4-varianter som har det.
# libc6-dev är bra för kompilering.
# Lägg till libpipewire-0.3-dev och relaterade dev-paket för PipeWire om applikationer ska byggas mot det.
SYSTEM_PACKAGES_ADD="raspberrypi-kernel raspberrypi-bootloader firmware-brcm80211 libc6-dev libpipewire-0.3-dev libspa-0.2-dev"

# Ta bort onödiga paket
PACKAGES_EXCLUDE=""
EOF
echo "$CONFIG_FILE_FULL_PATH skapad."

# 6. Se till att vi är i rpi-image-gen-katalogen innan bygget
cd "$RPI_IMAGE_GEN_FULL_PATH"
echo "Arbetskatalog: $(pwd)"

# 7. Starta byggprocessen
echo "Startar ./build.sh..."
echo "Detta kan ta lång tid. Output kommer att visas nedan."
echo "Konfigurationsfil som används: $CONFIG_FILE_FULL_PATH"

./build.sh -c "$CONFIG_FILE_FULL_PATH"

echo "=== Byggskriptet har slutförts ==="
echo "Om allt gick bra bör din image-fil finnas i en underkatalog till $(pwd)/work/ eller $(pwd)/deploy/" 