# Use an ARM64-based image as the base (if you're on an ARM host)
FROM arm64v8/ubuntu:latest

# Install qemu-user-static and binfmt-support
RUN apt-get update && apt-get install -y qemu-user-static binfmt-support

# Install any necessary dependencies for your x86 binary
RUN apt-get install -y libc6-i386

# Copy the x86 binary into the container
# Replace 'my_x86_binary' with the actual x86 executable file you want to run.

# Grant execution permission to the binary
RUN chmod +x /usr/local/bin/my_x86_binary

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
