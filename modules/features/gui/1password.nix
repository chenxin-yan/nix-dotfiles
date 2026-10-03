let
  app.programs._1password-gui.enable = true;
in
{
  features._1password = {
    darwin = app;
    nixos =
      {
        host,
        config,
        lib,
        ...
      }:
      {
        imports = [ app ];
        # NixOS only: polkit lets this user unlock op and the browser through the app.
        programs._1password-gui.polkitPolicyOwners = [ host.login ];

        # Start hidden in the tray at login so the SSH agent and op unlock are
        # ready. systemd's xdg-autostart generator reads /etc/xdg/autostart.
        environment.etc."xdg/autostart/1password.desktop".text = ''
          [Desktop Entry]
          Type=Application
          Name=1Password
          Exec=${lib.getExe config.programs._1password-gui.package} --silent
        '';
      };
    # SSH and git use the keys in 1Password through its agent, so a desktop
    # needs no key file. The agent itself is switched on in 1Password →
    # Settings → Developer; that setting lives in the app, not in a file.
    homeManager =
      { pkgs, ... }:
      {
        programs.ssh.settings."*".IdentityAgent =
          if pkgs.stdenv.hostPlatform.isDarwin then
            ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"''
          else
            "~/.1password/agent.sock";

        # Which keys the agent offers: those in the Personal vault. Replaces
        # the file 1Password writes from "Configure for SSH Agent".
        xdg.configFile."1Password/ssh/agent.toml" = {
          force = true;
          text = ''
            [[ssh-keys]]
            vault = "Personal"
          '';
        };
      };
  };
}
