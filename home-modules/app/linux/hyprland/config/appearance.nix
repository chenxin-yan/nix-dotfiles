{
  general = {
    gaps_in = 5;
    gaps_out = 5;

    border_size = 1;

    "col.active_border" = "$accent";
    "col.inactive_border" = "$surface0";

    resize_on_border = true;

    allow_tearing = false;

    layout = "dwindle";
  };

  decoration = {
    rounding = 10;

    active_opacity = 1.0;
    inactive_opacity = 1.0;

    blur = {
      enabled = true;
      size = 3;
      passes = 3;
      new_optimizations = true;
      vibrancy = 0.1696;
      ignore_opacity = true;
    };
  };

  animations = {
    enabled = true;

    bezier = [
      "myBezier, 0.05, 0.9, 0.1, 1.05"
    ];

    animation = [
      # Speed up windows animations
      "windows, 1, 4, myBezier"
      "windowsOut, 1, 4, default, popin 80%"

      # Speed up border color changes
      "border, 1, 5, default"
      "borderangle, 1, 4, default"

      # Speed up fade animations
      "fade, 1, 4, default"

      # Disable workspace switching animations
      "workspaces, 0"

      # Speed up specialized window animations
      "specialWorkspace, 1, 4, default, slidevert"
    ];
  };

  dwindle = {
    pseudotile = true;
    preserve_split = true;
  };

  misc = {
    force_default_wallpaper = 0;
    disable_hyprland_logo = true;
    disable_splash_rendering = true;
    vrr = 0;
  };

  layerrule = [
    # vicinae blur and transparency
    "blur, vicinae"
    "ignorealpha 0, vicinae"
    # disable fade animation for vicinae
    "noanim, vicinae"
  ];
}
