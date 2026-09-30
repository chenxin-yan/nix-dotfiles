let
  service.services.tailscale.enable = true;
in
{
  features.tailscale = {
    darwin = service;
    nixos = service;
  };
}
