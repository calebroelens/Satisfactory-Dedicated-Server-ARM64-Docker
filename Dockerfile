# Use an ARM64-based image as the base (if you're on an ARM host)
FROM arm64v8/ubuntu:latest

# Install qemu-user-static and binfmt-support
RUN apt-get update && apt-get install -y qemu-user-static binfmt-support

# Command to execute the x86 binary using qemu when the container starts
RUN apt update && apt install -y curl python3 sudo expect-dev software-properties-common

RUN useradd -m steam

USER steam

# Go to /home/steam/Steam
WORKDIR /home/steam/Steam

# Download and extract SteamCMD
RUN curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -

# Copy init-server.sh to container
COPY --chmod=755 --chown=steam:steam ./init-server.sh /home/steam/init-server.sh

ENTRYPOINT /home/steam/init-server.sh
