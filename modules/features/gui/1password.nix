let
  desktop = {
    programs._1password.enable = true;
    programs._1password-gui.enable = true;
  };
in
{
  features._1password = {
    darwin = desktop;
    nixos = desktop;
  };
}
