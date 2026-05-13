FROM quay.io/fedora/fedora-kinoite:43

LABEL org.opencontainers.image.title="Velaris"
LABEL org.opencontainers.image.description="Velaris OS"
LABEL org.opencontainers.image.version="1.0"

# Assets
COPY assets/wallpaper-desktop.png /usr/share/wallpapers/velaris-desktop.png
COPY assets/wallpaper-lock.png /usr/share/wallpapers/velaris-lock.png
COPY assets/logo.png /usr/share/pixmaps/velaris-logo.png

# Identidade Velaris
RUN sed -i 's/^PRETTY_NAME=.*/PRETTY_NAME="Velaris 1.0"/' /usr/lib/os-release || true && \
    sed -i 's/^NAME=.*/NAME="Velaris"/' /usr/lib/os-release || true

# Wallpaper desktop
RUN mkdir -p /etc/skel/.config && \
    printf '[Wallpaper]\nImage=file:///usr/share/wallpapers/velaris-desktop.png\n' \
    > /etc/skel/.config/plasma-org.kde.plasma.desktop-appletsrc

# Tela de bloqueio
RUN printf '[Greeter][Wallpaper][org.kde.image][General]\nImage=file:///usr/share/wallpapers/velaris-lock.png\n' \
    > /etc/skel/.config/kscreenlockerrc

# Logo menu iniciar
RUN cp /usr/share/pixmaps/velaris-logo.png /usr/share/pixmaps/start-here.png || true
