{
  features.mosh-server.nixos = {
    programs.mosh.enable = true;

    networking.firewall.allowedUDPPortRanges = [
      {
        from = 60000;
        to = 61000;
      }
    ];
  };
}
