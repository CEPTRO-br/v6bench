# hadolint ignore=DL3007
FROM kathara/base:latest

# hadolint ignore=DL3013
RUN apt-get update && \
    apt install -y kmod wget && \
    wget -q https://github.com/NICMx/Jool/releases/download/v4.1.15/jool-dkms_4.1.15-1_all.deb && \
    wget -q https://github.com/NICMx/Jool/releases/download/v4.1.15/jool-tools_4.1.15-1_amd64.deb && \
    apt install -y ./jool-* && \
    rm -rf ./jool-* && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
