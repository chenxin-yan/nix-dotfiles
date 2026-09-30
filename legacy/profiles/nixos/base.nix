# Minimal prerequisites for `just switch`, without the optional features in
# ./default.nix. Boot, disks, users, network and desktop stay with the host.
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  programs.nh.enable = true;
}
