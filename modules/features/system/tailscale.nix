{
  features.tailscale = {
    darwin.services.tailscale.enable = true;
    nixos =
      { config, lib, ... }:
      let
        authKey = (config.sops.secrets or { }).tailscale-authkey or null;
      in
      {
        services.tailscale.enable = true;
        # A NixOS host that declares this secret (a one-off key, root-owned)
        # joins the tailnet on its first switch instead of `tailscale up`.
        services.tailscale.authKeyFile = lib.mkIf (authKey != null) authKey.path;
      };
  };
}
