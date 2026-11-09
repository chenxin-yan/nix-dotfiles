{ inputs, ... }:
{
  features.markdown.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        mermaid-cli
        glow

        markdownlint-cli2
        # TODO: back to pkgs once nixpkgs-cached is removed from flake.nix.
        inputs.nixpkgs-cached.legacyPackages.${pkgs.stdenv.hostPlatform.system}.marksman
        harper
      ];

      home.file.".markdownlint.json".source = ./config/markdownlint.jsonc;
    };
}
