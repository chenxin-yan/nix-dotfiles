{
  features.web.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        curlie
        awscli2
        doppler
        infisical
        jless
        ngrok
        nginx

        wget
        mongosh

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
