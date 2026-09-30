let
  fonts =
    { pkgs, ... }:
    {
      fonts.packages = [
        pkgs.nerd-fonts.jetbrains-mono
        pkgs.geist-font
      ];
    };
in
{
  features.fonts = {
    darwin = fonts;
    nixos = fonts;
  };
}
