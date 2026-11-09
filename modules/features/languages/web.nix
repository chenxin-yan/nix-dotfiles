{ inputs, ... }:
{
  features.web.homeManager =
    { pkgs, ... }:
    let
      # TODO: back to pkgs once nixpkgs-cached is removed from flake.nix.
      cached = inputs.nixpkgs-cached.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      home.packages = with pkgs; [
        curlie
        wget

        # editor
        vscode-langservers-extracted
        tailwindcss-language-server
        emmet-language-server
        prettierd
        biome
        cached.oxfmt
        cached.oxlint
        taplo
        yaml-language-server
      ];
    };
}
