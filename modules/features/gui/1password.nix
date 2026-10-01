let
  app.programs._1password-gui.enable = true;
in
{
  features._1password = {
    darwin = app;
    nixos = app;
  };
}
