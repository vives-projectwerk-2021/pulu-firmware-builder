# Pulu Firmware Builder v1.3.0
# Thomas Crombez 23/10/2021

# Dependencies:
#   gcc-arm-none-eabi 9-2019-q4-major
#   python 3.7.10

FROM python:3.7.10-slim

WORKDIR /firmware-builder
VOLUME /firmware

# Install mercurial git rsync and curl
RUN apt clean
RUN apt-get update
RUN apt-get install -y mercurial git rsync curl

# Install mbed-cli mbed-tools and pip for python 3.7.10
RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install mbed-cli mbed-tools

# Install gcc-arm 9-2019-q4-major
RUN curl https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-rm/9-2019q4/gcc-arm-none-eabi-9-2019-q4-major-x86_64-linux.tar.bz2 -o /tmp/gcc-arm-none-eabi-9-2019-q4-major.bz2
RUN tar xjf /tmp/gcc-arm-none-eabi-9-2019-q4-major.bz2 -C /usr/share/
RUN rm /tmp/gcc-arm-none-eabi-9-2019-q4-major.bz2

# Install python dependancies
COPY requirements.txt ./
RUN pip install -r requirements.txt

# Clone latest pulu-firmware
# ADD https://api.github.com/repos/vives-projectwerk-2021/pulu-main-firmware/git/refs/heads/main /tmp/pulu-repo-version.json
# RUN git clone -b main https://github.com/vives-projectwerk-2021/pulu-main-firmware.git /tmp/pulu-repo/
ADD https://api.github.com/repos/vives-projectwerk-2021/pulu-main-firmware/git/refs/heads/combine /tmp/pulu-repo-version.json
RUN git clone -b combine https://github.com/vives-projectwerk-2021/pulu-main-firmware.git /tmp/pulu-repo/
RUN rsync -av /tmp/pulu-repo/ /firmware-builder/ --exclude src/ --exclude .git/

# Configure mbed
RUN mbed config -G GCC_ARM_PATH "/usr/share/gcc-arm-none-eabi-9-2019-q4-major/bin/"
RUN mbed config -G TOOLCHAIN "GCC_ARM"
RUN mbed config -G TARGET "NUCLEO_L476RG"

# Install mbed libraries
RUN mkdir .git
RUN mbed-tools deploy

# Create default main.cpp
RUN mkdir src
RUN echo "int main() { return 0; }" >> src/main.cpp

# Compile mbed for caching
RUN mkdir -p .cache/default .cache/nucleo .cache/fake

RUN mbed compile --app-config mbed_app.json
RUN mv BUILD .cache/default

RUN mbed compile --app-config mbed_app_nucleo.json
RUN mv BUILD .cache/nucleo

RUN mbed compile --app-config mbed_app_nucleo_fake.json
RUN mv BUILD .cache/fake

# Copy pulu build script
COPY pulu-build.sh .
RUN chmod +x pulu-build.sh

ARG VERSION="latest"
ENV BUILDER_VERSION=$VERSION
ENV CONFIG=$CONFIG

ENTRYPOINT [ "./pulu-build.sh" ]
