FROM debian:stable-slim

ARG BITCOIN_VERSION=latest
ENV BITCOIN_HOME=/home/bitcoin/.bitcoin
ENV PATH="/opt/bitcoin/bin:${PATH}"

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates curl procps passwd; \
    rm -rf /var/lib/apt/lists/*; \
    arch="$(uname -m)"; \
    case "${arch}" in x86_64) bitcoin_arch="x86_64" ;; aarch64) bitcoin_arch="aarch64" ;; *) echo "Arquitectura no soportada: ${arch}"; exit 1 ;; esac; \
    if [ "${BITCOIN_VERSION}" = "latest" ]; then BITCOIN_VERSION="$(curl -fsSL https://bitcoincore.org/bin/ | grep -oE 'bitcoin-core-[0-9]+\.[0-9]+(\.[0-9]+)?' | sed 's/bitcoin-core-//' | sort -Vu | tail -n 1)"; fi; \
    base_url="https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}"; \
    archive="bitcoin-${BITCOIN_VERSION}-${bitcoin_arch}-linux-gnu.tar.gz"; \
    mkdir -p /opt/bitcoin /tmp/bitcoin; \
    curl -fL --retry 3 "${base_url}/${archive}" -o "/tmp/bitcoin/${archive}"; \
    curl -fL --retry 3 "${base_url}/SHA256SUMS" -o /tmp/bitcoin/SHA256SUMS; \
    awk -v file="${archive}" '$2 == file { print }' /tmp/bitcoin/SHA256SUMS > /tmp/bitcoin/SHA256SUMS.selected; \
    test "$(wc -l < /tmp/bitcoin/SHA256SUMS.selected)" -eq 1; \
    cd /tmp/bitcoin; sha256sum -c SHA256SUMS.selected; \
    tar -xzf "${archive}" --strip-components=1 -C /opt/bitcoin; \
    groupadd --system bitcoin; useradd --system --gid bitcoin --create-home --home-dir /home/bitcoin --shell /usr/sbin/nologin bitcoin; \
    mkdir -p "${BITCOIN_HOME}"; chown -R bitcoin:bitcoin /home/bitcoin /opt/bitcoin; rm -rf /tmp/bitcoin

USER bitcoin
WORKDIR /home/bitcoin
VOLUME ["/home/bitcoin/.bitcoin"]
EXPOSE 18444 18443
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=5 CMD ["bitcoin-cli", "-regtest", "-datadir=/home/bitcoin/.bitcoin", "getblockchaininfo"]
ENTRYPOINT ["bitcoind"]
CMD ["-regtest=1", "-daemon=0", "-printtoconsole=1"]
