# Base image for the development container.
FROM ubuntu:24.04

# Set noninteractive package installs and runtime paths for Android and npm tools.
ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV ANDROID_HOME=/opt/android-sdk
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH=/opt/android-sdk/cmdline-tools/latest/bin:/opt/android-sdk/platform-tools:$PATH
ENV PATH=$PATH:/usr/local/share/npm-global/bin

# Install system packages used for development, debugging, device tooling, and sudo access.
RUN apt-get update && apt-get install -y --no-install-recommends \
  aggregate \
  adb \
  bubblewrap \
  build-essential \
  ca-certificates \
  cmake \
  curl \
  direnv \
  dnsutils \
  fastboot \
  ffmpeg \
  fzf \
  gcc-arm-none-eabi \
  gh \
  git \
  gnupg2 \
  graphviz \
  imagemagick \
  iproute2 \
  ipset \
  iptables \
  jq \
  less \
  libusb-1.0-0-dev \
  man-db \
  make \
  minicom \
  ninja-build \
  openjdk-17-jdk-headless \
  openocd \
  picocom \
  pkg-config \
  procps \
  python3 \
  python3-pip \
  python3-venv \
  ripgrep \
  screen \
  shellcheck \
  sqlite3 \
  sudo \
  tcpdump \
  unzip \
  usbutils \
  v4l-utils \
  wget \
  wireshark-common \
  zip \
  zsh \
  && rm -rf /var/lib/apt/lists/*

# Install Node.js so Codex can be installed from npm.
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
  && apt-get install -y nodejs \
  && rm -rf /var/lib/apt/lists/*

# Create the shared directories used by the Android SDK and global npm installs.
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools /usr/local/share/npm-global \
  && chmod 755 /usr/local/share/npm-global

# Download and unpack the Android SDK command-line tools.
RUN cd /tmp \
  && wget -q https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip -O android-cmdline-tools.zip \
  && unzip -q android-cmdline-tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools \
  && mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest \
  && rm -f android-cmdline-tools.zip

# Accept Android licenses and install the SDK components needed by the image.
RUN yes | sdkmanager --licenses >/dev/null \
  && sdkmanager \
    "platform-tools" \
    "build-tools;35.0.0" \
    "platforms;android-35"

# Allow the Codex package version to be overridden at build time.
ARG CODEX_VERSION=latest

# Install the Codex CLI globally and clear the npm cache afterward.
RUN npm install -g @openai/codex@${CODEX_VERSION} \
  && npm cache clean --force

# Limit sudo to package management.
RUN printf '%s\n' 'ubuntu ALL=(root) NOPASSWD: /usr/bin/apt, /usr/bin/apt-get, /usr/bin/dpkg' >/etc/sudoers.d/ubuntu-package-manager \
  && chmod 0440 /etc/sudoers.d/ubuntu-package-manager

# Start the container in the Codex CLI by default.
CMD ["bash"]
