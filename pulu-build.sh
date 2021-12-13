#!/bin/bash

clear

VERSION="${1:-latest}"
CONFIG="${2:-default}"
case $CONFIG in
	nucleo)
		APP_CONFIG="mbed_app_nucleo.json"
		;;
	nucleo_fake)
		APP_CONFIG="mbed_app_nucleo_fake.json"
		;;
	*)
		CONFIG="default"
		APP_CONFIG="mbed_app.json"
		;;
esac

echo "Pulu Firmware Builder $BUILDER_VERSION"
echo "Using app-config: $APP_CONFIG"

echo "Updating libraries..."
cp -r /firmware/*.lib /firmware-builder/
mbed-tools deploy

echo "Compiling pulu (with cache)"
cp -r /firmware/src/. /firmware-builder/src/

mv /cache/$CONFIG/BUILD /firmware-builder/

mbed compile --app-config $APP_CONFIG --artifact-name pulu-$VERSION-$CONFIG

echo "pulu-$VERSION-$CONFIG compiled!"

mkdir -p /firmware/BUILD
cp /firmware-builder/BUILD/NUCLEO_L476RG/GCC_ARM/pulu-$VERSION-$CONFIG.bin /firmware/BUILD/pulu-$VERSION-$CONFIG.bin