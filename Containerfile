FROM quay.io/toolbx/ubuntu-toolbox:22.04

LABEL com.github.containers.toolbox="true" \
      usage="This image is meant to be used with the toolbox or distrobox command" \
      summary="A cloud-native terminal experience" \
      maintainer="ragib@example.com"

# Setup vscode
RUN apt update
RUN apt install wget gpg apt-transport-https
RUN echo "code code/add-microsoft-repo boolean true" | sudo debconf-set-selections
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
RUN install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
RUN echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
RUN rm -f packages.microsoft.gpg
RUN apt update
RUN apt install code

# Setup dependencies
RUN apt update
RUN apt install build-essential direnv

# Install mise
RUN wget https://mise.jdx.dev/mise-latest-linux-x64 && \
    mv mise-latest-linux-x64 /usr/local/bin/mise && \
    chmod a+x /usr/local/bin/mise

# Activate mise
RUN echo 'eval "$(/usr/local/bin/mise activate bash)"' >> /etc/bashrc

# Activate direnv
RUN echo 'eval "$(direnv hook bash)"' >> /etc/bashrc

# Run docker on the host
RUN ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/docker
