#!/bin/bash

clear
echo "Pulu Firmware Builder $BUILDER_VERSION"

VERSION="${1:-latest}"

echo "Updating libraries..."
cp -r /firmware/*.lib /firmware-builder/
mbed-tools deploy

echo "Compiling pulu (with cache)"
cp -r /firmware/src/. /firmware-builder/src/

if [ ! -f /firmware-builder/src/config.h ]; then
    echo "Using default pulu config"
    cp /firmware/src/config.example.h /firmware-builder/src/config.h
fi

mbed compile --artifact-name pulu-$VERSION

echo "pulu-$VERSION compiled!"

mkdir -p /firmware/BUILD
cp /firmware-builder/BUILD/NUCLEO_L476RG/GCC_ARM/pulu-$VERSION.bin /firmware/BUILD/pulu-$VERSION.bin