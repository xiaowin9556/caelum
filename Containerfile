FROM ghcr.io/ublue-os/bazzite:latest

LABEL org.opencontainers.image.title="Velaris"
LABEL org.opencontainers.image.description="Velaris OS"
LABEL org.opencontainers.image.version="1.0"

# ==================== ZRAM 4GB ====================
RUN echo "[zram0]" > /etc/systemd/zram-generator.conf && \
    echo "zram-size = 4096" >> /etc/systemd/zram-generator.conf && \
    echo "compression-algorithm = zstd" >> /etc/systemd/zram-generator.conf && \
    echo "swap-priority = 100" >> /etc/systemd/zram-generator.conf

# ==================== Assets ====================
COPY assets/wallpaper-desktop.png /usr/share/wallpapers/velaris-desktop.png
COPY assets/wallpaper-lock.png /usr/share/wallpapers/velaris-lock.png
COPY assets/logo.png /usr/share/pixmaps/velaris-logo.png

# ==================== Remover fcitx5 ====================
RUN rpm-ostree override remove \
    fcitx5 fcitx5-chewing fcitx5-chinese-addons fcitx5-chinese-addons-data \
    fcitx5-configtool fcitx5-data fcitx5-gtk fcitx5-gtk2 fcitx5-gtk3 \
    fcitx5-gtk4 fcitx5-hangul fcitx5-libs fcitx5-libthai fcitx5-lua \
    fcitx5-m17n fcitx5-mozc fcitx5-qt fcitx5-qt5 fcitx5-qt6 \
    fcitx5-qt-libfcitx5qt6widgets fcitx5-qt-libfcitx5qtdbus fcitx5-qt-qt6gui \
    fcitx5-sayura fcitx5-unikey kcm-fcitx5 libime libime-data \
    || true

# ==================== Remover Steam, Lutris e outros ====================
RUN rpm-ostree override remove \
    lutris \
    steam \
    steam-devices \
    input-remapper \
    || true

# ==================== Instalar Firefox ====================
RUN rpm-ostree install firefox || true

# ==================== Esconder Kate do menu ====================
RUN mkdir -p /usr/share/applications && \
    cat > /usr/share/applications/org.kde.kate.desktop << 'EOF'
[Desktop Entry]
Type=Application
Hidden=true
EOF

# ==================== Identidade Velaris (os-release) ====================
RUN cp /usr/lib/os-release /usr/lib/os-release.bak && \
    sed -i 's/Bazzite/Velaris/gI' /usr/lib/os-release && \
    sed -i 's/bazzite/velaris/gI' /usr/lib/os-release && \
    sed -i '/^PRETTY_NAME=/d' /usr/lib/os-release && \
    echo 'PRETTY_NAME="Velaris 1.0"' >> /usr/lib/os-release && \
    echo 'NAME="Velaris"' >> /usr/lib/os-release && \
    echo 'VARIANT="KDE Plasma"' >> /usr/lib/os-release || true

# ==================== Remover arquivos do Bazzite ====================
RUN rm -f /etc/profile.d/bazzite-*.sh \
    /usr/share/ublue-os/motd/*.md \
    /usr/share/applications/bazzite-*.desktop \
    /usr/share/applications/webapp-manager.desktop \
    /usr/share/applications/bold-brew.desktop \
    /usr/share/applications/discourse.desktop || true

# ==================== Wallpaper Desktop (Plasma) ====================
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

# ==================== Game Mode ====================
COPY scripts/game-mode.sh /usr/local/bin/velaris-game-mode
RUN chmod +x /usr/local/bin/velaris-game-mode

# ==================== Limpeza ====================
RUN rpm-ostree cleanup -m && \
    rm -rf /var/cache/* /tmp/* /var/tmp/* || true
