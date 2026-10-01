{ inputs, ... }:
let
  settings = {
    # Explicit because the NixOS default is empty when sshd is off.
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    # Only the ed25519 key is a recipient; don't import the RSA one as GPG.
    gnupg.sshKeyPaths = [ ];
  };
in
{
  features.secrets = {
    darwin = {
      imports = [ inputs.sops-nix.darwinModules.sops ];
      sops = settings;
    };
    nixos = {
      imports = [ inputs.sops-nix.nixosModules.sops ];
      sops = settings;
    };
    # For the `just secret*` recipes.
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          sops
          ssh-to-age
          jq
        ];
      };
  };
}
