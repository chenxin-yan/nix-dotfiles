{
  pkgs,
  lib,
  config,
  ...
}:

{
  options = {
    dev.typescript.enable = lib.mkEnableOption "enables TypeScript development tools";
  };

  config = lib.mkIf config.dev.typescript.enable {
    home.packages = with pkgs; [
      nodejs_26
      pnpm
      ni

      # editor
      vtsls
      astro-language-server
      prisma-language-server
      vscode-js-debug
    ];

    programs.bun.enable = true;
    home.sessionPath = [ "$HOME/.bun/bin" ];

    # Refuse to install package versions younger than 1 day, mitigating
    # supply-chain attacks that rely on installing a just-published release.
    # npm's equivalent (min-release-age=1) lives in ~/.npmrc, which holds an
    # auth token and is therefore not managed here.
    programs.bun.settings.install.minimumReleaseAge = 86400; # seconds
    xdg.configFile."pnpm/config.yaml".text = ''
      minimumReleaseAge: 1440 # minutes
    '';
  };
}
