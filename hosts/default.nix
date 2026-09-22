# Registered machines. The attribute name is the flake target, the managed
# hostname (networking.hostName) and the argument to `just switch <target>`.
# Register only real machines; per-host account/state facts live in
# hosts/<name>/configuration.nix and hosts/<name>/home.nix.
{
  macbook = {
    system = "aarch64-darwin";
    login = "yanchenxin";
  };
  work-macbook = {
    system = "aarch64-darwin";
    login = "chenxin-yan";
  };
  minipc = {
    system = "x86_64-linux";
    login = "cyan";
  };
}
