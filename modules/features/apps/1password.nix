{
  features._1password = {
    darwin = {
      programs._1password.enable = true;
      programs._1password-gui.enable = true;
    };

    # CLI only: minipc is headless.
    nixos.programs._1password.enable = true;
  };
}
