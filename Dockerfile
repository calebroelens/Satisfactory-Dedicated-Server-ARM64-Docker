FROM --platform=linux/arm64 golang:1.21.6-bookworm as builder

RUN 	apt update \
		&& apt install -y git curl gcc musl-dev

RUN 	git clone https://github.com/gorcon/rcon-cli.git \
		&& cd rcon-cli/ \
		&& go get -v -t -d ./... \
		&& CGO_ENABLED=1 go build -ldflags "-s -w -X main.ServiceVersion=docker" -v ./cmd/gorcon \
		&& mv gorcon /tmp/rcon
# Use Ubuntu 22.04 as base
FROM --platform=linux/arm64 ubuntu:22.04

COPY --from=builder /tmp/rcon /usr/local/bin/rcon

# Install cURL, Python 3, sudo, unbuffer and the package for "add-apt-repository"
RUN apt update && apt install -y curl python3 sudo expect-dev software-properties-common

# Fex build dependencies
RUN     apt update && apt -y install software-properties-common wget curl fuse squashfs-tools zenity libsdl2-2.0-0 libepoxy0 libgl1 squashfuse \
        && add-apt-repository ppa:fex-emu/fex \
        && apt update \
        && wget https://ppa.launchpadcontent.net/fex-emu/fex/ubuntu/pool/main/f/fex-emu-armv8.0/fex-emu-armv8.0_2312.1~l_arm64.deb \
        && dpkg -i fex-emu-armv8.0_2312.1~l_arm64.deb \
        && apt -y install fex-emu-binfmt32 fex-emu-binfmt64

# compiling FEX
RUN	apt update \
        && apt -y install curl git iproute2 libssl-dev squashfuse fuse squashfs-tools tzdata tar wget zip build-essential unzip gdb gettext screen numactl libc6 libstdc++6 \
	&& wget http://launchpadlibrarian.net/668077130/libssl1.1_1.1.1f-1ubuntu2.19_arm64.deb \
  	&& dpkg -i libssl1.1_1.1.1f-1ubuntu2.19_arm64.deb \
        && ls -la /usr/local/bin

# Create user steam
RUN useradd -m steam

# InstallL FEX root FS
RUN sudo -u steam bash -c "unbuffer FEXRootFSFetcher -y -x"

# Change user to steam
USER steam

# Go to /home/steam/Steam
WORKDIR /home/steam/Steam

# Download and extract SteamCMD
RUN curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -

# Copy init-server.sh to container
COPY --chmod=755 --chown=steam:steam ./init-server.sh /home/steam/init-server.sh
RUN chmod +x /home/steam/init-server.sh

# Run it
ENTRYPOINT /home/steam/init-server.sh