{
  env = [
    "XCURSOR_SIZE,24"
    "HYPRCURSOR_SIZE,24"

    # Scaling
    "GDK_SCALE,2"
    "QT_SCALE_FACTOR,2"

    # QT
    "QT_QPA_PLATFORM,wayland"
    "QT_QPA_PLATFORMTHEME,qt5ct"
    "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
    "QT_AUTO_SCREEN_SCALE_FACTOR,1"
    "QT_STYLE_OVERRIDE,kvantum"

    # Toolkit Backend Variables
    "GDK_BACKEND,wayland,x11,*"
    "SDL_VIDEODRIVER,wayland"
    "CLUTTER_BACKEND,wayland"

    # XDG Specifications
    "XDG_CURRENT_DESKTOP,Hyprland"
    "XDG_SESSION_TYPE,wayland"
    "XDG_SESSION_DESKTOP,Hyprland"
  ];
}
