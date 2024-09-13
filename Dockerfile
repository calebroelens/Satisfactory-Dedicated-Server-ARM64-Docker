# Use Ubuntu 22.04 as base
FROM --platform=linux/arm64 golang:1.21.6-bookworm as builder

RUN 	apt update \
		&& apt install -y git curl gcc musl-dev

RUN 	git clone https://github.com/gorcon/rcon-cli.git \
		&& cd rcon-cli/ \
		&& go get -v -t -d ./... \
		&& CGO_ENABLED=1 go build -ldflags "-s -w -X main.ServiceVersion=docker" -v ./cmd/gorcon \
		&& mv gorcon /tmp/rcon

FROM --platform=linux/arm64 ubuntu:22.04

ENV  DEBIAN_FRONTEND noninteractive

## add container user
RUN  useradd -m -d /home/container -s /bin/bash container

COPY --from=builder /tmp/rcon /usr/local/bin/rcon

RUN     apt update && apt -y install software-properties-common wget curl fuse squashfs-tools zenity libsdl2-2.0-0 libepoxy0 libgl1 squashfuse \
        && add-apt-repository ppa:fex-emu/fex \
        && apt update \
        && wget https://ppa.launchpadcontent.net/fex-emu/fex/ubuntu/pool/main/f/fex-emu-armv8.0/fex-emu-armv8.0_2312.1~l_arm64.deb \
        && dpkg -i fex-emu-armv8.0_2312.1~l_arm64.deb \
        && apt -y install fex-emu-binfmt32 fex-emu-binfmt64

RUN	apt update \
        && apt -y install curl git iproute2 libssl-dev squashfuse fuse squashfs-tools tzdata tar wget zip build-essential unzip gdb gettext screen numactl libc6 libstdc++6 \
        && wget http://launchpadlibrarian.net/668077130/libssl1.1_1.1.1f-1ubuntu2.19_arm64.deb \
        && dpkg -i libssl1.1_1.1.1f-1ubuntu2.19_arm64.deb \
        && ls -la /usr/local/bin

RUN		apt update \
        && apt install -y wget gnupg2 \
		&& wget https://itai-nelken.github.io/weekly-box86-debs/debian/box86.list -O /etc/apt/sources.list.d/box86.list \
		&& wget -qO- https://itai-nelken.github.io/weekly-box86-debs/debian/KEY.gpg | apt-key add - \
		&& apt update && apt install box86:armhf libc6 libc6:armhf -y \

RUN         wget https://ryanfortner.github.io/box64-debs/box64.list -O /etc/apt/sources.list.d/box64.list \
            && wget -qO- https://ryanfortner.github.io/box64-debs/KEY.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/box64-debs-archive-keyring.gpg \
            && apt update && apt install box64-rpi4arm64 -y


RUN     dpkg --add-architecture armhf && \
        apt-get update && \
        apt-get install --yes --no-install-recommends libc6:armhf libstdc++6:armhf gcc-arm-linux-gnueabihf libc6:armhf libncurses5:armhf libsdl2-image-2.0-0:armhf && \
        apt-get -y autoremove && \
        apt-get clean autoclean && \
        rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists

ENV         DEBIAN_FRONTEND=noninteractive

RUN         dpkg --add-architecture armhf \
				&& apt update \
				&& apt upgrade -y \
				&& apt -y --no-install-recommends install ca-certificates curl git wget

RUN         apt install -y libc6:armhf libncurses5:armhf libsdl2-2.0-0:armhf libsdl2-image-2.0-0:armhf libsdl2-mixer-2.0-0:armhf libsdl2-ttf-2.0-0:armhf libopenal1:armhf libpng16-16:armhf libfontconfig1:armhf libxcomposite1:armhf libbz2-1.0:armhf libxtst6:armhf libsm6:armhf libice6:armhf libgl1:armhf libxinerama1:armhf libxdamage1:armhf

ENV     STEAMOS=1
ENV     STEAM_RUNTIME=1
ENV     DBUS_FATAL_WARNINGS=0

RUN	dpkg --add-architecture armhf

WORKDIR /home/container

COPY  ./entrypoint.sh /entrypoint.sh
CMD   [ "/bin/bash", "/entrypoint.sh" ]