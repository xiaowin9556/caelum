FROM ghcr.io/ublue-os/bazzite:latest

LABEL org.opencontainers.image.title="Velaris"
LABEL org.opencontainers.image.description="Velaris OS"
LABEL org.opencontainers.image.version="1.0"

# 1. Agrupar modificações de pacotes em uma única transação
# Isso evita conflitos de base e reduz o tamanho da imagem
RUN rpm-ostree override remove \
    libime libime-data fcitx5 fcitx5-chewing fcitx5-chinese-addons \
    fcitx5-chinese-addons-data fcitx5-configtool fcitx5-data fcitx5-gtk \
    fcitx5-gtk2 fcitx5-gtk3 fcitx5-gtk4 fcitx5-hangul fcitx5-libs \
    fcitx5-libthai fcitx5-lua fcitx5-m17n fcitx5-mozc fcitx5-qt \
    fcitx5-qt5 fcitx5-qt6 fcitx5-qt-libfcitx5qt6widgets \
    fcitx5-qt-libfcitx5qtdbus fcitx5-qt-qt6gui fcitx5-sayura \
    fcitx5-unikey kcm-fcitx5 lutris steam steam-devices \
    steamdeck-kde-presets-desktop input-remapper && \
    rpm-ostree install firefox && \
    rpm-ostree cleanup -m

# 2. Configuração de ZRAM (Melhor usar o diretório /usr/lib para persistência em builds uBlue)
RUN echo "[zram0]" > /usr/lib/systemd/zram-generator.conf && \
    echo "zram-size = 4096" >> /usr/lib/systemd/zram-generator.conf && \
    echo "compression-algorithm = zstd" >> /usr/lib/systemd/zram-generator.conf && \
    echo "swap-priority = 100" >> /usr/lib/systemd/zram-generator.conf

# 3. Assets e Identidade (Use o caminho correto para o os-release)
COPY assets/ /tmp/assets/
RUN cp /tmp/assets/wallpaper-desktop.png /usr/share/wallpapers/velaris-desktop.png && \
    cp /tmp/assets/wallpaper-lock.png /usr/share/wallpapers/velaris-lock.png && \
    cp /tmp/assets/logo.png /usr/share/pixmaps/velaris-logo.png && \
    # Patch os-release
    sed -i 's/Bazzite/Velaris/g' /usr/lib/os-release && \
    sed -i 's/bazzite/velaris/g' /usr/lib/os-release

# 4. Esconder Kate (Correto, mas certifique-se que o diretório existe)
RUN mkdir -p /usr/share/applications && \
    echo -e "[Desktop Entry]\nHidden=true" > /usr/share/applications/org.kde.kate.desktop

# 5. Skel e Configurações de Usuário
# Nota: O /etc/skel só funciona para NOVOS usuários criados após o boot.
RUN mkdir -p /etc/skel/.config && \
    echo -e "[Wallpaper]\nImage=file:///usr/share/wallpapers/velaris-desktop.png" > /etc/skel/.config/plasma-org.kde.plasma.desktop-appletsrc && \
    echo -e "[Greeter][Wallpaper][org.kde.image][General]\nImage=file:///usr/share/wallpapers/velaris-lock.png" > /etc/skel/.config/kscreenlockerrc

# 6. Limpeza de Bloat do Bazzite
RUN rm -f /etc/profile.d/bazzite-*.sh \
    /usr/share/ublue-os/motd/*.md \
    /usr/share/applications/bazzite-portal.desktop \
    /usr/share/applications/bazzite-documentation.desktop \
    /usr/share/applications/bazzite-update.desktop \
    /usr/share/applications/webapp-manager.desktop \
    /usr/share/applications/bold-brew.desktop \
    /usr/share/applications/discourse.desktop

COPY scripts/game-mode.sh /usr/local/bin/velaris-game-mode
RUN chmod +x /usr/local/bin/velaris-game-mode && rm -rf /tmp/*FROM ghcr.io/ublue-os/bazzite:latest

LABEL org.opencontainers.image.title="Velaris"
LABEL org.opencontainers.image.description="Velaris OS"
LABEL org.opencontainers.image.version="1.0"

# 1. Agrupar modificações de pacotes em uma única transação
# Isso evita conflitos de base e reduz o tamanho da imagem
RUN rpm-ostree override remove \
    libime libime-data fcitx5 fcitx5-chewing fcitx5-chinese-addons \
    fcitx5-chinese-addons-data fcitx5-configtool fcitx5-data fcitx5-gtk \
    fcitx5-gtk2 fcitx5-gtk3 fcitx5-gtk4 fcitx5-hangul fcitx5-libs \
    fcitx5-libthai fcitx5-lua fcitx5-m17n fcitx5-mozc fcitx5-qt \
    fcitx5-qt5 fcitx5-qt6 fcitx5-qt-libfcitx5qt6widgets \
    fcitx5-qt-libfcitx5qtdbus fcitx5-qt-qt6gui fcitx5-sayura \
    fcitx5-unikey kcm-fcitx5 lutris steam steam-devices \
    steamdeck-kde-presets-desktop input-remapper && \
    rpm-ostree install firefox && \
    rpm-ostree cleanup -m

# 2. Configuração de ZRAM (Melhor usar o diretório /usr/lib para persistência em builds uBlue)
RUN echo "[zram0]" > /usr/lib/systemd/zram-generator.conf && \
    echo "zram-size = 4096" >> /usr/lib/systemd/zram-generator.conf && \
    echo "compression-algorithm = zstd" >> /usr/lib/systemd/zram-generator.conf && \
    echo "swap-priority = 100" >> /usr/lib/systemd/zram-generator.conf

# 3. Assets e Identidade (Use o caminho correto para o os-release)
COPY assets/ /tmp/assets/
RUN cp /tmp/assets/wallpaper-desktop.png /usr/share/wallpapers/velaris-desktop.png && \
    cp /tmp/assets/wallpaper-lock.png /usr/share/wallpapers/velaris-lock.png && \
    cp /tmp/assets/logo.png /usr/share/pixmaps/velaris-logo.png && \
    # Patch os-release
    sed -i 's/Bazzite/Velaris/g' /usr/lib/os-release && \
    sed -i 's/bazzite/velaris/g' /usr/lib/os-release

# 4. Esconder Kate (Correto, mas certifique-se que o diretório existe)
RUN mkdir -p /usr/share/applications && \
    echo -e "[Desktop Entry]\nHidden=true" > /usr/share/applications/org.kde.kate.desktop

# 5. Skel e Configurações de Usuário
# Nota: O /etc/skel só funciona para NOVOS usuários criados após o boot.
RUN mkdir -p /etc/skel/.config && \
    echo -e "[Wallpaper]\nImage=file:///usr/share/wallpapers/velaris-desktop.png" > /etc/skel/.config/plasma-org.kde.plasma.desktop-appletsrc && \
    echo -e "[Greeter][Wallpaper][org.kde.image][General]\nImage=file:///usr/share/wallpapers/velaris-lock.png" > /etc/skel/.config/kscreenlockerrc

# 6. Limpeza de Bloat do Bazzite
RUN rm -f /etc/profile.d/bazzite-*.sh \
    /usr/share/ublue-os/motd/*.md \
    /usr/share/applications/bazzite-portal.desktop \
    /usr/share/applications/bazzite-documentation.desktop \
    /usr/share/applications/bazzite-update.desktop \
    /usr/share/applications/webapp-manager.desktop \
    /usr/share/applications/bold-brew.desktop \
    /usr/share/applications/discourse.desktop

COPY scripts/game-mode.sh /usr/local/bin/velaris-game-mode
RUN chmod +x /usr/local/bin/velaris-game-mode && rm -rf /tmp/*
