VERSION=latest

all:
	@ docker build . -t ghcr.io/vives-projectwerk-2021/pulu-firmware-builder:$(VERSION) --build-arg VERSION=$(VERSION)