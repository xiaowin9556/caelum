FROM ghcr.io/ublue-os/bazzite:latest

LABEL org.opencontainers.image.title="Velaris"
LABEL org.opencontainers.image.description="Velaris OS"
LABEL org.opencontainers.image.version="1.0"

# ZRAM 4GB
RUN echo "[zram0]" > /etc/systemd/zram-generator.conf && \
    echo "zram-size = 4096" >> /etc/systemd/zram-generator.conf && \
    echo "compression-algorithm = zstd" >> /etc/systemd/zram-generator.conf && \
    echo "swap-priority = 100" >> /etc/systemd/zram-generator.conf

# Assets
COPY assets/wallpaper-desktop.png /usr/share/wallpapers/velaris-desktop.png
COPY assets/wallpaper-lock.png /usr/share/wallpapers/velaris-lock.png
COPY assets/logo.png /usr/share/pixmaps/velaris-logo.png

# Identidade Velaris
RUN sed -i 's/^PRETTY_NAME=.*/PRETTY_NAME="Velaris 1.0"/' /usr/lib/os-release || true && \
    sed -i 's/^NAME=.*/NAME="Velaris"/' /usr/lib/os-release || true

# Wallpaper desktop
RUN mkdir -p /etc/skel/.config && \
    echo "[Wallpaper]" > /etc/skel/.config/plasma-org.kde.plasma.desktop-appletsrc && \
    echo "Image=file:///usr/share/wallpapers/velaris-desktop.png" >> /etc/skel/.config/plasma-org.kde.plasma.desktop-appletsrc

# Tela de bloqueio
RUN echo "[Greeter][Wallpaper][org.kde.image][General]" > /etc/skel/.config/kscreenlockerrc && \
    echo "Image=file:///usr/share/wallpapers/velaris-lock.png" >> /etc/skel/.config/kscreenlockerrc

# Logo menu iniciar
RUN cp /usr/share/pixmaps/velaris-logo.png /usr/share/pixmaps/start-here.png || true

# Fastfetch
RUN mkdir -p /etc/fastfetch && \
    echo '{"logo": {"source": "/usr/share/pixmaps/velaris-logo.png", "type": "kitty"}, "display": {"separator": " "}}' \
    > /etc/fastfetch/config.jsonc
