FROM quay.io/toolbx/ubuntu-toolbox:22.04

LABEL com.github.containers.toolbox="true" \
      usage="This image is meant to be used with the toolbox or distrobox command" \
      summary="A cloud-native terminal experience" \
      maintainer="ragib@example.com"

# Setup essentials
RUN apt update
RUN apt install -y apt-transport-https curl git gpg wget 

# Setup vscode repo
RUN echo "code code/add-microsoft-repo boolean true" | sudo debconf-set-selections
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
RUN install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
RUN echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
RUN rm -f packages.microsoft.gpg

# Setup vscode and build dependencies
RUN apt update
RUN apt install -y build-essential code direnv pkg-config libpython3.10-dev openjdk-11-jdk libpq5 libpq-dev npm python3-pip musl-tools cmake zlib1g-dev libsasl2-dev python3-venv clang liblzma-dev libxml2-dev libxmlsec1-dev

# Setup rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN rustup toolchain install 1.72.1
RUN rustup default 1.72.1
RUN rustup target add wasm32-wasi --toolchain=1.72.1
RUN cargo install cargo-nextest

# Install mise
RUN wget https://mise.jdx.dev/mise-latest-linux-x64 && \
    mv mise-latest-linux-x64 /usr/local/bin/mise && \
    chmod a+x /usr/local/bin/mise

# Activate mise
RUN echo 'eval "$(/usr/local/bin/mise activate bash)"' >> /etc/bash.bashrc

# Activate direnv
RUN echo 'eval "$(direnv hook bash)"' >> /etc/bash.bashrc

# Activate default distrobox prompt
RUN echo '[ -e /etc/profile.d/distrobox_profile.sh ] && . /etc/profile.d/distrobox_profile.sh' >> /etc/skel/.bashrc

# Run docker on the host
RUN ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/docker
