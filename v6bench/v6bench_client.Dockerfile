# hadolint ignore=DL3007
FROM kathara/base:latest

# hadolint ignore=DL3013
RUN pip install scanapi==2.13.3 --break-system-packages --no-cache-dir && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
