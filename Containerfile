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
COPY assets/logo.png /usr/share/pixmaps/velaris-logo.png

# Identidade Velaris
RUN sed -i 's/^PRETTY_NAME=.*/PRETTY_NAME="Velaris 1.0"/' /usr/lib/os-release || true && \
    sed -i 's/^NAME=.*/NAME="Velaris"/' /usr/lib/os-release || true

# Trocar logo do Plymouth (boot)
RUN mkdir -p /usr/share/plymouth/themes/velaris && \
    cp /usr/share/pixmaps/velaris-logo.png /usr/share/plymouth/themes/velaris/watermark.png && \
    cp /usr/share/pixmaps/velaris-logo.png /boot/velaris-logo.png || true

# Trocar nome no GRUB
RUN find /boot -name "grub.cfg" -exec sed -i 's/Bazzite/Velaris/g' {} \; || true && \
    find /boot -name "grub.cfg" -exec sed -i 's/bazzite/velaris/g' {} \; || true

# Pular OOBE/setup
RUN rm -f /usr/share/applications/org.kde.plasma-welcome.desktop || true && \
    rm -f /usr/share/autostart/org.kde.plasma-welcome.desktop || true && \
    mkdir -p /etc/skel/.config && \
    echo "[General]" > /etc/skel/.config/plasma-welcomerc && \
    echo "ShouldShowOnStartup=false" >> /etc/skel/.config/plasma-welcomerc

# Wallpaper desktop — para todos os usuários
RUN mkdir -p /etc/skel/.local/share/plasma/desktoptheme && \
    mkdir -p /etc/skel/.config && \
    printf '[Wallpaper]\nImage=file:///usr/share/wallpapers/velaris-desktop.png\n' \
    > /etc/skel/.config/plasma-org.kde.plasma.desktop-appletsrc

# Tela de bloqueio
RUN printf '[Greeter][Wallpaper][org.kde.image][General]\nImage=file:///usr/share/wallpapers/velaris-lock.png\n' \
    > /etc/skel/.config/kscreenlockerrc

# Logo menu iniciar
RUN cp /usr/share/pixmaps/velaris-logo.png /usr/share/pixmaps/start-here.png || true

# Fastfetch
RUN mkdir -p /etc/fastfetch && \
    printf '{"logo": {"source": "/usr/share/pixmaps/velaris-logo.png", "type": "kitty"}, "display": {"separator": " "}}\n' \
    > /etc/fastfetch/config.jsonc

# Limpar cache
RUN rpm-ostree cleanup -m && \
    rm -rf /var/cache/* /tmp/* || true
