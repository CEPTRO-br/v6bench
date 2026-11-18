# hadolint ignore=DL3007
FROM kathara/base:latest

# hadolint ignore=DL3013
RUN pip install "curlify2<2.0.0,>=1.0.1" scanapi==2.13.2 --break-system-packages --no-cache-dir && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*