FROM ghcr.io/ublue-os/bazzite:latest

LABEL org.opencontainers.image.title="Velaris"
LABEL org.opencontainers.image.description="Velaris OS - Custom Bazzite KDE"
LABEL org.opencontainers.image.version="1.0"
LABEL org.opencontainers.image.source="https://github.com/xiaowin9556/caelum"

# ==================== ZRAM 4GB ====================
RUN echo "[zram0]" > /etc/systemd/zram-generator.conf && \
    echo "zram-size = 4096" >> /etc/systemd/zram-generator.conf && \
    echo "compression-algorithm = zstd" >> /etc/systemd/zram-generator.conf && \
    echo "swap-priority = 100" >> /etc/systemd/zram-generator.conf

# ==================== Assets ====================
COPY assets/wallpaper-desktop.png /usr/share/wallpapers/velaris-desktop.png
COPY assets/wallpaper-lock.png /usr/share/wallpapers/velaris-lock.png
COPY assets/logo.png /usr/share/pixmaps/velaris-logo.png

# ==================== Identidade Velaris (os-release) - CORRIGIDO ====================
RUN cp /usr/lib/os-release /usr/lib/os-release.bak && \
    sed -i 's/Bazzite/Velaris/gI' /usr/lib/os-release && \
    sed -i 's/bazzite/velaris/gI' /usr/lib/os-release && \
    sed -i '/^PRETTY_NAME=/d' /usr/lib/os-release && \
    echo 'PRETTY_NAME="Velaris 1.0"' >> /usr/lib/os-release && \
    echo 'NAME="Velaris"' >> /usr/lib/os-release && \
    echo 'VARIANT="KDE Plasma"' >> /usr/lib/os-release

# ==================== Remover vestígios do Bazzite (branding) ====================
RUN rm -f /etc/profile.d/bazzite-*.sh \
    /usr/share/ublue-os/motd/*.md \
    /usr/share/applications/bazzite-*.desktop || true

# ==================== Wallpaper Desktop ====================
RUN mkdir -p /etc/skel/.config && \
    cat > /etc/skel/.config/plasma-org.kde.plasma.desktop-appletsrc << 'EOF'
[Containments][1]
activityId=
lastScreen=0
plugin=org.kde.plasma.desktop
type=Desktop

[Containments][1][Wallpaper][org.kde.image][General]
Image=file:///usr/share/wallpapers/velaris-desktop.png
EOF

# ==================== Tela de Bloqueio ====================
RUN mkdir -p /etc/skel/.config && \
    cat > /etc/skel/.config/kscreenlockerrc << 'EOF'
[Greeter][Wallpaper][org.kde.image][General]
Image=file:///usr/share/wallpapers/velaris-lock.png
EOF

# ==================== Logo do Menu Iniciar ====================
RUN cp -f /usr/share/pixmaps/velaris-logo.png /usr/share/pixmaps/start-here.png || true

# ==================== Fastfetch ====================
RUN mkdir -p /etc/fastfetch && \
    cat > /etc/fastfetch/config.jsonc << 'EOF'
{
  "logo": {
    "source": "/usr/share/pixmaps/velaris-logo.png",
    "type": "kitty"
  },
  "display": {
    "separator": " "
  }
}
EOF

# ==================== Limpeza final ====================
RUN rpm-ostree cleanup -m && \
    rm -rf /var/cache/* /tmp/* /var/tmp/* || true
