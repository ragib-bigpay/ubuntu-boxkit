FROM quay.io/toolbx/ubuntu-toolbox:22.04

LABEL com.github.containers.toolbox="true" \
      usage="This image is meant to be used with the toolbox or distrobox command" \
      summary="A cloud-native terminal experience" \
      maintainer="ragib@example.com"

# Setup essentials
# RUN apt update
# RUN apt install -y apt-transport-https curl git gpg wget 

# Setup vscode repo
RUN echo "code code/add-microsoft-repo boolean true" | sudo debconf-set-selections
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
RUN install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
RUN echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
RUN rm -f packages.microsoft.gpg

# Setup vscode and build dependencies
RUN apt update
RUN apt install -y apt-transport-https curl git gpg wget
RUN apt install -y build-essential code direnv
RUN apt install -y pkg-config libpython3.10-dev openjdk-11-jdk libpq5 libpq-dev npm python3-pip musl-tools cmake zlib1g-dev libsasl2-dev python3-venv clang liblzma-dev libxml2-dev libxmlsec1-dev
RUN apt install -y linux-headers-$(uname -r) build-essential libssl-dev libreadline-dev zlib1g-dev libcurl4-openssl-dev uuid-dev icu-devtools libicu-dev

# Install mise
RUN wget https://mise.jdx.dev/mise-latest-linux-x64 && \
    mv mise-latest-linux-x64 /usr/local/bin/mise && \
    chmod a+x /usr/local/bin/mise

# Activate mise
COPY mise-config.toml /etc/mise/config.toml
RUN echo 'eval "$(/usr/local/bin/mise activate bash)"' >> /etc/profile

# Activate direnv
RUN echo 'eval "$(direnv hook bash)"' >> /etc/profile

# Activate default distrobox prompt
RUN echo '[ -e /etc/profile.d/distrobox_profile.sh ] && . /etc/profile.d/distrobox_profile.sh' >> /etc/skel/.bashrc

# # Setup scripts
# COPY setup-dev.sh /usr/local/bin/setup-dev
# RUN chmod a+x /usr/local/bin/setup-dev

# Run docker on the host
RUN ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/docker
