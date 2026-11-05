{
  features.typescript.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        nodejs_26
        pnpm
        ni
        deno

        # editor
        vtsls
        astro-language-server
        svelte-language-server
        prisma-language-server
      ];

      # vtsls loads @astrojs/ts-plugin (bundled in astro-language-server) from
      # <location>/node_modules; the Neovim config points at this directory.
      xdg.dataFile."nvim/astro-ts-plugin/node_modules/@astrojs/ts-plugin".source =
        "${pkgs.astro-language-server}/lib/node_modules/astro-language-server/packages/language-tools/ts-plugin";

      programs.bun.enable = true;
      home.sessionPath = [ "$HOME/.bun/bin" ];
    };
}
