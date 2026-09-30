# Minimal prerequisites for `just switch` on NixOS, without the optional
# features in ./server.nix. The onboarding wizard selects only this for a new
# machine; boot, disks, users, network and desktop stay with the host.
{
  features.nixos-base.nixos = {
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    programs.nh.enable = true;
  };
}
