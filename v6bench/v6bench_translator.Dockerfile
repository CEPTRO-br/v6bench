# hadolint ignore=DL3007
FROM kathara/base:latest

# hadolint ignore=DL3013
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends tayga && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
