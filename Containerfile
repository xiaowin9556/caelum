FROM ghcr.io/ublue-os/bazzite:latest

LABEL org.opencontainers.image.title="Velaris"
LABEL org.opencontainers.image.description="Velaris OS - Personalizado"
LABEL org.opencontainers.image.version="1.0"

# 1. Performance: Configuração de ZRAM (4GB)
RUN mkdir -p /usr/lib/systemd/zram-generator.conf.d && \
    echo -e "[zram0]\nzram-size = 4096\ncompression-algorithm = zstd\nswap-priority = 100" \
    > /usr/lib/systemd/zram-generator.conf.d/99-velaris.conf

# 2. Importar arquivos de personalização
# Certifique-se de que a pasta 'assets' existe com as imagens
COPY assets/ /tmp/assets/

# 3. Identidade do Sistema (os-release)
RUN sed -i 's/Bazzite/Velaris/g' /usr/lib/os-release && \
    sed -i 's/bazzite/velaris/g' /usr/lib/os-release

# 4. Personalização Visual (Wallpapers e Logos)
RUN mkdir -p /usr/share/wallpapers /usr/share/pixmaps && \
    cp /tmp/assets/wallpaper-desktop.png /usr/share/wallpapers/velaris-desktop.png || true && \
    cp /tmp/assets/wallpaper-lock.png /usr/share/wallpapers/velaris-lock.png || true && \
    cp /tmp/assets/logo.png /usr/share/pixmaps/velaris-logo.png || true && \
    cp /usr/share/pixmaps/velaris-logo.png /usr/share/pixmaps/start-here.png || true

# 5. Configurações de Usuário (Desktop, Tela de Bloqueio e Fastfetch)
RUN mkdir -p /usr/etc/skel/.config /usr/etc/fastfetch && \
    # Wallpaper do Plasma
    echo -e "[Wallpaper]\nImage=file:///usr/share/wallpapers/velaris-desktop.png" \
    > /usr/etc/skel/.config/plasma-org.kde.plasma.desktop-appletsrc && \
    # Wallpaper da Tela de Bloqueio
    echo -e "[Greeter][Wallpaper][org.kde.image][General]\nImage=file:///usr/share/wallpapers/velaris-lock.png" \
    > /usr/etc/skel/.config/kscreenlockerrc && \
    # Logotipo no Fastfetch
    echo '{"logo": {"source": "/usr/share/pixmaps/velaris-logo.png", "type": "kitty"}, "display": {"separator": " "}}' \
    > /usr/etc/fastfetch/config.jsonc

# 6. Limpeza de arquivos temporários da Build
RUN rm -rf /tmp/assets /var/cache/*
