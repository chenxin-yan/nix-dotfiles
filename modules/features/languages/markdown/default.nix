{
  features.markdown.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        mermaid-cli
        glow

        markdownlint-cli2
        marksman
        harper
      ];

      home.file.".markdownlint.json".source = ./config/markdownlint.jsonc;
    };
}
