FROM ghcr.io/ublue-os/bazzite:latest

LABEL org.opencontainers.image.title="Velaris"
LABEL org.opencontainers.image.description="Velaris OS"
LABEL org.opencontainers.image.version="1.0"

# 1. Configuração de ZRAM (Modo Robusto)
RUN mkdir -p /usr/lib/systemd/zram-generator.conf.d && \
    echo -e "[zram0]\nzram-size = 4096\ncompression-algorithm = zstd\nswap-priority = 100" \
    > /usr/lib/systemd/zram-generator.conf.d/99-velaris.conf

# 2. Preparação de Arquivos Temporários
# Certifique-se de que as pastas 'assets' e 'scripts' existem no seu repositório
COPY assets/ /tmp/assets/
COPY scripts/ /tmp/scripts/

# 3. Gestão de Pacotes (Remoção Dinâmica + Instalação)
# Filtra pacotes que podem não existir na base para evitar erro 'exit code 1'
RUN PACKAGES_TO_REMOVE="libime libime-data fcitx5 fcitx5-chewing fcitx5-chinese-addons \
    fcitx5-chinese-addons-data fcitx5-configtool fcitx5-data fcitx5-gtk \
    fcitx5-gtk2 fcitx5-gtk3 fcitx5-gtk4 fcitx5-hangul fcitx5-libs \
    fcitx5-libthai fcitx5-lua fcitx5-m17n fcitx5-mozc fcitx5-qt \
    fcitx5-qt5 fcitx5-qt6 fcitx5-qt-libfcitx5qt6widgets \
    fcitx5-qt-libfcitx5qtdbus fcitx5-qt-qt6gui fcitx5-sayura \
    fcitx5-unikey kcm-fcitx5 lutris steam steam-devices \
    steamdeck-kde-presets-desktop input-remapper" && \
    REMOVE_LIST="" && \
    for pkg in $PACKAGES_TO_REMOVE; do \
        if rpm -q $pkg >/dev/null 2>&1; then \
            REMOVE_LIST="$REMOVE_LIST $pkg"; \
        fi; \
    done && \
    if [ -n "$REMOVE_LIST" ]; then \
        rpm-ostree override remove $REMOVE_LIST; \
    fi && \
    rpm-ostree install firefox && \
    rpm-ostree cleanup -m

# 4. Identidade Visual e Wallpapers
RUN mkdir -p /usr/share/wallpapers /usr/share/pixmaps /usr/share/applications && \
    [ -f /tmp/assets/wallpaper-desktop.png ] && cp /tmp/assets/wallpaper-desktop.png /usr/share/wallpapers/velaris-desktop.png || true && \
    [ -f /tmp/assets/wallpaper-lock.png ] && cp /tmp/assets/wallpaper-lock.png /usr/share/wallpapers/velaris-lock.png || true && \
    [ -f /tmp/assets/logo.png ] && cp /tmp/assets/logo.png /usr/share/pixmaps/velaris-logo.png || true && \
    cp /usr/share/pixmaps/velaris-logo.png /usr/share/pixmaps/start-here.png || true && \
    # Patch no os-release para mudar o nome da distro
    sed -i 's/Bazzite/Velaris/g' /usr/lib/os-release && \
    sed -i 's/bazzite/velaris/g' /usr/lib/os-release

# 5. Configurações de Interface (Skel e Fastfetch)
RUN mkdir -p /usr/etc/skel/.config /usr/etc/fastfetch && \
    # Wallpaper Plasma
    echo -e "[Wallpaper]\nImage=file:///usr/share/wallpapers/velaris-desktop.png" \
    > /usr/etc/skel/.config/plasma-org.kde.plasma.desktop-appletsrc && \
    # Lockscreen
    echo -e "[Greeter][Wallpaper][org.kde.image][General]\nImage=file:///usr/share/wallpapers/velaris-lock.png" \
    > /usr/etc/skel/.config/kscreenlockerrc && \
    # Config Fastfetch
    echo '{"logo": {"source": "/usr/share/pixmaps/velaris-logo.png", "type": "kitty"}, "display": {"separator": " "}}' \
    > /usr/etc/fastfetch/config.jsonc

# 6. Scripts e Permissões
RUN mkdir -p /usr/local/bin && \
    if [ -f /tmp/scripts/game-mode.sh ]; then \
        cp /tmp/scripts/game-mode.sh /usr/local/bin/velaris-game-mode && \
        chmod +x /usr/local/bin/velaris-game-mode; \
    fi

# 7. Limpeza de Bloatware do Bazzite e Ocultar Apps
RUN echo -e "[Desktop Entry]\nHidden=true" > /usr/share/applications/org.kde.kate.desktop && \
    # Remove ícones indesejados no menu
    rm -f /usr/share/applications/bazzite-portal.desktop \
         /usr/share/applications/bazzite-documentation.desktop \
         /usr/share/applications/bazzite-update.desktop \
         /usr/share/applications/webapp-manager.desktop \
         /usr/share/applications/bold-brew.desktop \
         /usr/share/applications/discourse.desktop \
         /usr/etc/profile.d/bazzite-*.sh || true && \
    # Limpeza final de arquivos temporários da build
    rm -rf /tmp/assets /tmp/scripts /var/cache/*
