{
  lib,
  config,
  host,
  ...
}:

{
  options = {
    nixos.podman.enable = lib.mkEnableOption "enables podman container manager";
  };

  config = lib.mkIf config.nixos.podman.enable {
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    users.users.${host.login}.extraGroups = [ "podman" ];
  };
}
