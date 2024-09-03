FROM docker.io/ubuntu:22.04
LABEL maintainer="DeftDawg <DeftDawg@gmail.com>"
LABEL maintainer="LongracksLabs <longrackslabs@gmail.com>"

# Set default values for build arguments
ARG UID=1000
ARG GID=1000
ARG USER=appuser
ARG CLEAN="NO"
ARG BUILD_U="NO"
ARG BUILD_D="NO"
ARG BUILD_S="NO"
ARG BUILD_I="NO"

# Only add the user if not root
RUN [ "$UID" != "0" ] && groupadd -g $GID $USER && useradd -m -u $UID -g $GID -s /bin/bash $USER

# Disable interactive package configuration
RUN apt-get update && \
    echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Add a deb-src
RUN echo deb-src http://archive.ubuntu.com/ubuntu \
    $(grep VERSION_CODENAME /etc/*release | cut -d= -f2) main universe >> /etc/apt/sources.list 

RUN apt-get update && apt-get install -y \
    autoconf \
    build-essential \
    cmake \
    curl \
    eglexternalplatform-dev \
    extra-cmake-modules \
    file \
    git \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-libav \
    libcairo2-dev \
    libcurl4-openssl-dev \
    libdbus-1-dev \
    libglew-dev \
    libglu1-mesa-dev \
    libgstreamer1.0-dev \
    libgstreamerd-3-dev \ 
    libgstreamer-plugins-base1.0-dev \
    libgstreamer-plugins-good1.0-dev \
    libgtk-3-dev \
    libosmesa6-dev \
    libsecret-1-dev \
    libsoup2.4-dev \
    libssl3 \
    libssl-dev \
    libtool \
    libudev-dev \
    libwayland-dev \
    libwebkit2gtk-4.0-dev \
    libxkbcommon-dev \
    locales \
    locales-all \
    m4 \
    ninja-build \
    pkgconf \
    sudo \
    wayland-protocols \
    wget

# Change your locale here if you want. See the output
# of `locale -a` to pick the correct string formatting.
ENV LC_ALL=en_US.utf8
RUN locale-gen $LC_ALL

# Set this so that Orca Slicer doesn't complain about
# the CA cert path on every startup
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

# Copy the project files into the container
COPY ./ OrcaSlicer

# Set the working directory
WORKDIR /OrcaSlicer

# Conditional steps based on build arguments

# Clean build directories if specified
RUN if [ "$CLEAN" = "YES" ]; then ./BuildLinux.sh -c; fi

# Update system dependencies
RUN if [ "$BUILD_U" = "YES" ]; then ./BuildLinux.sh -u; fi

# Build dependencies in ./deps
RUN if [ "$BUILD_D" = "YES" ]; then ./BuildLinux.sh -d; fi

# Build slic3r
RUN if [ "$BUILD_S" = "YES" ]; then ./BuildLinux.sh -s; fi

# Build AppImage
ENV container=podman
RUN if [ "$BUILD_I" = "YES" ]; then ./BuildLinux.sh -i; fi


# It's easier to run Orca Slicer as the same username,
# UID, and GID as your workstation. Since we bind mount
# your home directory into the container, it's handy
# to keep permissions the same. Just in case, defaults
# are root.
SHELL ["/bin/bash", "-l", "-c"]
ARG USER=root
ARG UID=0
ARG GID=0

# Create the user with the correct home directory and permissions
RUN if [[ "$UID" != "0" ]]; then \
      if ! id -u $USER >/dev/null 2>&1; then \
        groupadd -f -g $GID $USER && \
        useradd -m -u $UID -g $GID -s /bin/bash $USER; \
      fi; \
      mkdir -p /home/$USER/.config/OrcaSlicer && \
      chown -R $UID:$GID /home/$USER; \
    fi

# Set the working directory to the user's home
WORKDIR /home/$USER

# Ensure the application knows where the home directory is
ENV HOME=/home/$USER

# for debugging, use an entrypoint instead of CMD to start a bash shell
ENTRYPOINT ["/bin/bash"]

# then start docker into shell with
# docker run -it --entrypoint /bin/bash orcaslicer

# Using an entrypoint instead of CMD because the binary
# accepts several command line arguments.
# ENTRYPOINT ["/OrcaSlicer/build/package/bin/orca-slicer"]
