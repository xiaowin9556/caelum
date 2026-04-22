FROM ghcr.io/ublue-os/bazzite:latest

# Metadados
LABEL org.opencontainers.image.title="Caelum"
LABEL org.opencontainers.image.description="Caelum OS - The sky starts here"
LABEL org.opencontainers.image.version="1.0"

# Configurar ZRAM 4GB
RUN echo "[zram0]" > /etc/systemd/zram-generator.conf && \
    echo "zram-size = 4096" >> /etc/systemd/zram-generator.conf && \
    echo "compression-algorithm = zstd" >> /etc/systemd/zram-generator.conf && \
    echo "swap-priority = 100" >> /etc/systemd/zram-generator.conf
