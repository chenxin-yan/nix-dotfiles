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

      programs.bun.enable = true;
      home.sessionPath = [ "$HOME/.bun/bin" ];
    };
}
