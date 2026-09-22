# Feature implementations only; selections live in profiles/home/*.nix.
{
  imports = [
    ./agents
    ./app
    ./cli
    ./core
    ./dev
  ];
}
