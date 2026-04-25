FROM ghcr.io/ublue-os/bazzite:latest

LABEL org.opencontainers.image.title="Velaris"
LABEL org.opencontainers.image.description="Velaris OS"
LABEL org.opencontainers.image.version="1.0"

# 1. ZRAM: Configurar de forma modular no /usr (Padrão Ostree)
RUN mkdir -p /usr/lib/systemd/zram-generator.conf.d && \
    echo -e "[zram0]\nzram-size = 4096\ncompression-algorithm = zstd\nswap-priority = 100" \
    > /usr/lib/systemd/zram-generator.conf.d/99-velaris.conf

# 2. Copiar os arquivos locais para dentro da imagem temporariamente
# Certifique-se de que as pastas 'assets' e 'scripts' estão junto ao Dockerfile
COPY assets/ /tmp/assets/
COPY scripts/ /tmp/scripts/

# 3. Gerenciamento de Pacotes (Com checagem dinâmica)
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

# 4. Configuração de Assets e Identidade Visual Velaris
RUN mkdir -p /usr/share/wallpapers /usr/share/pixmaps /usr/share/applications && \
    cp /tmp/assets/wallpaper-desktop.png /usr/share/wallpapers/velaris-desktop.png && \
    cp /tmp/assets/wallpaper-lock.png /usr/share/wallpapers/velaris-lock.png && \
    cp /tmp/assets/logo.png /usr/share/pixmaps/velaris-logo.png && \
    cp /usr/share/pixmaps/velaris-logo.png /usr/share/pixmaps/start-here.png && \
    # Modificar Identidade do Sistema Operacional
    sed -i 's/Bazzite/Velaris/g' /usr/lib/os-release && \
    sed -i 's/bazzite/velaris/g' /usr/lib/os-release

# 5. Configurações de Usuário Padrão (/usr/etc é mapeado para /etc no Ostree)
RUN mkdir -p /usr/etc/skel/.config /usr/etc/fastfetch /usr/etc/profile.d && \
    # Wallpaper Desktop
    echo -e "[Wallpaper]\nImage=file:///usr/share/wallpapers/velaris-desktop.png" \
    > /usr/etc/skel/.config/plasma-org.kde.plasma.desktop-appletsrc && \
    # Tela de Bloqueio
    echo -e "[Greeter][Wallpaper][org.kde.image][General]\nImage=file:///usr/share/wallpapers/velaris-lock.png" \
    > /usr/etc/skel/.config/kscreenlockerrc && \
    # Fastfetch
    echo '{"logo": {"source": "/usr/share/pixmaps/velaris-logo.png", "type": "kitty"}, "display": {"separator": " "}}' \
    > /usr/etc/fastfetch/config.jsonc

# 6. Scripts Adicionais
RUN cp /tmp/scripts/game-mode.sh /usr/local/bin/velaris-game-mode && \
    chmod +x /usr/local/bin/velaris-game-mode

# 7. Ocultar Apps Nativos e Limpar Bloatware do Bazzite
RUN echo -e "[Desktop Entry]\nHidden=true" > /usr/share/applications/org.kde.kate.desktop && \
    rm -f /usr/etc/profile.d/bazzite-*.sh \
    /usr/share/ublue-os/motd/*.md \
    /usr/share/applications/bazzite-portal.desktop \
    /usr/share/applications/bazzite-documentation.desktop \
    /usr/share/applications/bazzite-update.desktop \
    /usr/share/applications/webapp-manager.desktop \
    /usr/share/applications/bold-brew.desktop \
    /usr/share/applications/discourse.desktop && \
    # Limpar os arquivos copiados pro /tmp para deixar a imagem menor
    rm -rf /tmp/assets /tmp/scripts
