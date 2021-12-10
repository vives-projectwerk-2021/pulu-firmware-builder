#!/bin/bash

clear
echo "Pulu Firmware Builder $BUILDER_VERSION"
echo "Using config: $CONFIG"

VERSION="${1:-latest}"
CONFIG="${2:-default}"

echo "Updating libraries..."
cp -r /firmware/*.lib /firmware-builder/
mbed-tools deploy

echo "Compiling pulu (with cache)"
cp -r /firmware/src/. /firmware-builder/src/

ls /firmware-builder/src
cp -r /firmware-builder/.cache/$CONFIG/. /firmware-builder/src
ls /firmware-builder/src
ls /firmware-builder/.cache

mbed compile --artifact-name pulu-$VERSION

echo "pulu-$VERSION compiled!"

mkdir -p /firmware/BUILD
cp /firmware-builder/BUILD/NUCLEO_L476RG/GCC_ARM/pulu-$VERSION.bin /firmware/BUILD/pulu-$VERSION.bin