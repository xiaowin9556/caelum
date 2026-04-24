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

# Remover fcitx5 + libime juntos
RUN rpm-ostree override remove \
    libime \
    libime-data \
    fcitx5 \
    fcitx5-chewing \
    fcitx5-chinese-addons \
    fcitx5-chinese-addons-data \
    fcitx5-configtool \
    fcitx5-data \
    fcitx5-gtk \
    fcitx5-gtk2 \
    fcitx5-gtk3 \
    fcitx5-gtk4 \
    fcitx5-hangul \
    fcitx5-libs \
    fcitx5-libthai \
    fcitx5-lua \
    fcitx5-m17n \
    fcitx5-mozc \
    fcitx5-qt \
    fcitx5-qt5 \
    fcitx5-qt6 \
    fcitx5-qt-libfcitx5qt6widgets \
    fcitx5-qt-libfcitx5qtdbus \
    fcitx5-qt-qt6gui \
    fcitx5-sayura \
    fcitx5-unikey \
    kcm-fcitx5 \
    || true

# Remover steam, lutris e outros
RUN rpm-ostree override remove \
    lutris \
    steam \
    steam-devices \
    steamdeck-kde-presets-desktop \
    input-remapper \
    || true

# Instalar Firefox
RUN rpm-ostree install firefox || true

# Esconder kate do menu sem remover (kwrite depende dele)
RUN echo -e "[Desktop Entry]\nHidden=true" > /usr/share/applications/org.kde.kate.desktop || true

# Identidade Velaris
RUN sed -i 's/bazzite/velaris/g' /usr/lib/os-release || true && \
    sed -i 's/Bazzite/Velaris/g' /usr/lib/os-release || true && \
    echo 'PRETTY_NAME="Velaris 1.0"' >> /usr/lib/os-release && \
    echo 'NAME="Velaris"' >> /usr/lib/os-release

# Remover arquivos do Bazzite
RUN rm -f /etc/profile.d/bazzite-*.sh || true && \
    rm -f /usr/share/ublue-os/motd/*.md || true && \
    rm -f /usr/share/applications/bazzite-portal.desktop || true && \
    rm -f /usr/share/applications/bazzite-documentation.desktop || true && \
    rm -f /usr/share/applications/bazzite-update.desktop || true && \
    rm -f /usr/share/applications/webapp-manager.desktop || true && \
    rm -f /usr/share/applications/bold-brew.desktop || true && \
    rm -f /usr/share/applications/discourse.desktop || true

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

# Game Mode
COPY scripts/game-mode.sh /usr/local/bin/velaris-game-mode
RUN chmod +x /usr/local/bin/velaris-game-mode

# Limpar cache
RUN rpm-ostree cleanup -m && \
    rm -rf /var/cache/* /tmp/* || true

