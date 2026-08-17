# Zed Remote Development container
# Zed (the GUI app) runs on your machine; this container hosts the
# headless Zed server + toolchain, reached over SSH.
#
# Build:    docker build -t zed-docker .
# Run:      docker compose up -d --build
# Connect:  zed ssh://dev@localhost:2222/home/dev/workspace

ARG USER=dev
ARG UID=1001
ARG SSH_PORT=22

FROM ubuntu:24.04

ARG USER
ARG UID
ARG SSH_PORT

# Base toolchain + sshd. curl is needed by Zed's server auto-install step.
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server \
    sudo \
    curl \
    ca-certificates \
    git \
    build-essential \
    pkg-config \
    file \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Dev user with passwordless sudo (password auth is disabled in sshd)
RUN useradd -m -u ${UID} -s /bin/bash ${USER} \
    && echo "${USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USER} \
    && chmod 440 /etc/sudoers.d/${USER}

RUN install -d -m 700 -o ${USER} -g ${USER} /home/${USER}/.ssh

COPY sshd_config /etc/ssh/sshd_config.d/zed.conf
RUN sed -i "s/^Port .*/Port ${SSH_PORT}/" /etc/ssh/sshd_config.d/zed.conf

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE ${SSH_PORT}
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D", "-e"]