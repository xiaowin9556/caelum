#!/bin/bash
# Velaris Game Mode

enable_game_mode() {
    # Overclock GPU +100MHz
    nvidia-smi --auto-boost-default=0 || true
    nvidia-settings -a GPUGraphicsClockOffset[3]=100 || true

    # CPU performance mode
    echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor || true

    # Ativar gamemode
    gamemoded -r || true

    notify-send "Velaris Game Mode" "Game Mode ativado! GPU +100MHz" --icon=/usr/share/pixmaps/velaris-logo.png
}

disable_game_mode() {
    nvidia-settings -a GPUGraphicsClockOffset[3]=0 || true
    echo schedutil | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor || true
    notify-send "Velaris Game Mode" "Game Mode desativado" --icon=/usr/share/pixmaps/velaris-logo.png
}

case "$1" in
    enable)  enable_game_mode ;;
    disable) disable_game_mode ;;
    *)       echo "Uso: velaris-game-mode [enable|disable]" ;;
esac
#!/bin/bash
# Velaris Game Mode

enable_game_mode() {
    # Overclock GPU +100MHz
    nvidia-smi --auto-boost-default=0 || true
    nvidia-settings -a GPUGraphicsClockOffset[3]=100 || true

    # CPU performance mode
    echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor || true

    # Ativar gamemode
    gamemoded -r || true

    notify-send "Velaris Game Mode" "Game Mode ativado! GPU +100MHz" --icon=/usr/share/pixmaps/velaris-logo.png
}

disable_game_mode() {
    nvidia-settings -a GPUGraphicsClockOffset[3]=0 || true
    echo schedutil | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor || true
    notify-send "Velaris Game Mode" "Game Mode desativado" --icon=/usr/share/pixmaps/velaris-logo.png
}

case "$1" in
    enable)  enable_game_mode ;;
    disable) disable_game_mode ;;
    *)       echo "Uso: velaris-game-mode [enable|disable]" ;;
esac

