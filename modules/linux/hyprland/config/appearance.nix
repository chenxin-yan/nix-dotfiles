{
  general = {
    gaps_in = 5;
    gaps_out = 5;

    border_size = 2;

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
}
