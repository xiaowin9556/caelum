FROM ghcr.io/ublue-os/bazzite:latest

# Metadados
LABEL org.opencontainers.image.title="Velaris"
LABEL org.opencontainers.image.description="Velaris OS"
LABEL org.opencontainers.image.version="1.0"

# Configurar ZRAM 4GB
RUN echo "[zram0]" > /etc/systemd/zram-generator.conf && \
    echo "zram-size = 4096" >> /etc/systemd/zram-generator.conf && \
    echo "compression-algorithm = zstd" >> /etc/systemd/zram-generator.conf && \
    echo "swap-priority = 100" >> /etc/systemd/zram-generator.conf

# Copiar assets do Velaris
COPY assets/wallpaper-desktop.png /usr/share/wallpapers/velaris-desktop.png
COPY assets/wallpaper-lock.png /usr/share/wallpapers/velaris-lock.png
COPY assets/logo.png /usr/share/pixmaps/velaris-logo.png

# Remover pacotes desnecessários
RUN rpm-ostree override remove \
    kate \
    khelpcenter \
    kinfocenter \
    || true

# Remover via rpm-ostree
RUN rpm-ostree uninstall \
    steam \
    lutris \
    sunshine \
    input-remapper \
    fcitx5 \
    || true

# Instalar Firefox
RUN rpm-ostree install firefox || true

# Trocar nome do boot pra Velaris
RUN sed -i 's/Bazzite/Velaris/g' /etc/default/grub || true
RUN sed -i 's/bazzite/velaris/g' /usr/lib/os-release || true
RUN echo "PRETTY_NAME=\"Velaris 1.0\"" >> /usr/lib/os-release || true
RUN echo "NAME=\"Velaris\"" >> /usr/lib/os-release || true

# Remover tutorial e boas vindas do terminal
RUN rm -f /etc/profile.d/bazzite-*.sh || true
RUN rm -f /usr/share/ublue-os/motd/*.md || true

# Wallpaper padrão KDE
RUN mkdir -p /etc/skel/.config/plasma-workspace/env && \
    echo "[Wallpaper]" > /etc/skel/.config/plasma-org.kde.plasma.desktop-appletsrc && \
    echo "Image=file:///usr/share/wallpapers/velaris-desktop.png" >> /etc/skel/.config/plasma-org.kde.plasma.desktop-appletsrc

# Tela de bloqueio
RUN mkdir -p /etc/skel/.config && \
    echo "[Greeter][Wallpaper][org.kde.image][General]" > /etc/skel/.config/kscreenlockerrc && \
    echo "Image=file:///usr/share/wallpapers/velaris-lock.png" >> /etc/skel/.config/kscreenlockerrc

# Logo do sistema no menu iniciar
RUN mkdir -p /usr/share/plasma/desktoptheme/default/icons && \
    cp /usr/share/pixmaps/velaris-logo.png /usr/share/pixmaps/start-here.png || true

# Fastfetch com logo Velaris
RUN mkdir -p /etc/fastfetch && \
    echo '{"logo": {"source": "/usr/share/pixmaps/velaris-logo.png", "type": "kitty"}, "display": {"separator": " "}}' \
    > /etc/fastfetch/config.jsonc || true

# Desabilitar serviços desnecessários
RUN systemctl disable \
    bazzite-portal.service \
    || true

# Modo Game — overclock automático
COPY scripts/game-mode.sh /usr/local/bin/velaris-game-mode
RUN chmod +x /usr/local/bin/velaris-game-mode

# Deletar cache após instalação
RUN rpm-ostree cleanup -m && \
    rm -rf /var/cache/* /tmp/* || true
