{
  lib,
  config,
  pkgs,
  ...
}:

{
  options = {
    nixos.audio.enable = lib.mkEnableOption "enables audio config";
  };

  config = lib.mkIf config.nixos.audio.enable {
    services.pulseaudio.enable = false;

    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    environment.systemPackages = with pkgs; [
      pavucontrol # PulseAudio Volume Control
      pamixer # Command-line mixer for PulseAudio
    ];
  };
}
