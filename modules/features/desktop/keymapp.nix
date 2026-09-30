{
  # ZSA keyboard configurator. A NixOS desktop also needs
  # hardware.keyboard.zsa.enable for its udev rules.
  features.keymapp.darwin =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.keymapp ];
    };
}
