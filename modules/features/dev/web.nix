{
  features.web.homeManager =
    { pkgs, ... }:
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
        oxfmt
        oxlint
        taplo
        yaml-language-server
      ];

      programs.jq.enable = true;
    };
}
