FROM ghcr.io/ublue-os/bazzite:latest

LABEL org.opencontainers.image.title="Velaris"
LABEL org.opencontainers.image.description="Velaris OS"
LABEL org.opencontainers.image.version="1.0"

# Remover repo problemático
RUN rm -f /etc/yum.repos.d/terra-mesa.repo || true

# ZRAM 4GB
RUN echo "[zram0]" > /etc/systemd/zram-generator.conf && \
    echo "zram-size = 4096" >> /etc/systemd/zram-generator.conf && \
    echo "compression-algorithm = zstd" >> /etc/systemd/zram-generator.conf && \
    echo "swap-priority = 100" >> /etc/systemd/zram-generator.conf

# Assets
COPY assets/wallpaper-desktop.png /usr/share/wallpapers/velaris-desktop.png
COPY assets/wallpaper-lock.png /usr/share/wallpapers/velaris-lock.png

# Pular setup/OOBE
RUN mkdir -p /etc/skel/.config && \
    echo "[General]" > /etc/skel/.config/plasma-welcomerc && \
    echo "ShouldShowOnStartup=false" >> /etc/skel/.config/plasma-welcomerc

# Wallpaper desktop
RUN printf '[Wallpaper]\nImage=file:///usr/share/wallpapers/velaris-desktop.png\n' \
    > /etc/skel/.config/plasma-org.kde.plasma.desktop-appletsrc

# Tela de bloqueio
RUN printf '[Greeter][Wallpaper][org.kde.image][General]\nImage=file:///usr/share/wallpapers/velaris-lock.png\n' \
    > /etc/skel/.config/kscreenlockerrc

# Limpar cache
RUN rpm-ostree cleanup -m && \
    rm -rf /var/cache/* /tmp/* || true
