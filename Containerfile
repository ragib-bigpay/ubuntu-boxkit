FROM quay.io/toolbx/ubuntu-toolbox:22.04

LABEL com.github.containers.toolbox="true" \
      usage="This image is meant to be used with the toolbox or distrobox command" \
      summary="A cloud-native terminal experience" \
      maintainer="ragib@example.com"

# Install essential packages
RUN apt-get update && \
    apt-get install -y curl wget gpg apt-transport-https software-properties-common && \
    apt-get clean

# Setup android-studio repo
RUN add-apt-repository -y ppa:maarten-fonville/android-studio
RUN echo 'if ! [[ "$PATH" =~ "/opt/android-studio/bin:" ]]; then' >> /etc/profile
RUN echo '    PATH="/opt/android-studio/bin:$PATH"' >> /etc/profile
RUN echo 'fi' >> /etc/profile
RUN echo 'export PATH' >> /etc/profile

# Setup vscode repo
RUN echo "code code/add-microsoft-repo boolean true" | debconf-set-selections && \
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg && \
    install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg && \
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | tee /etc/apt/sources.list.d/vscode.list > /dev/null && \
    rm -f packages.microsoft.gpg

# Setup google-chrome repo
RUN curl -fSsL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor | tee /usr/share/keyrings/google-chrome.gpg > /dev/null && \
    echo deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main | tee /etc/apt/sources.list.d/google-chrome.list

# Install packages
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y \
    # common tools
    git jq direnv
    # dev deps
    pkg-config libpython3.10-dev openjdk-11-jdk libpq5 libpq-dev npm python3-pip musl-tools cmake zlib1g-dev libsasl2-dev python3-venv clang liblzma-dev libxml2-dev libxmlsec1-dev \
    # asdf-postgres deps
    linux-headers-$(uname -r) build-essential libssl-dev libreadline-dev zlib1g-dev libcurl4-openssl-dev uuid-dev icu-devtools libicu-dev \
    # android studio deps
    libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386 libglib2.0-bin \
    # flutter deps
    clang cmake ninja-build pkg-config libgtk-3-dev && \
    apt-get clean

# Install mise
RUN wget -q https://mise.jdx.dev/mise-latest-linux-x64 && \
    mv mise-latest-linux-x64 /usr/local/bin/mise && \
    chmod a+x /usr/local/bin/mise

# Activate mise
COPY mise-config.toml /etc/mise/config.toml
RUN echo 'eval "$(/usr/local/bin/mise activate bash)"' >> /etc/profile

# Activate direnv
RUN echo 'eval "$(direnv hook bash)"' >> /etc/profile

# Activate default distrobox prompt
RUN echo '[ -e /etc/profile.d/distrobox_profile.sh ] && . /etc/profile.d/distrobox_profile.sh' >> /etc/skel/.bashrc

# Run docker on the host
RUN ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/docker
