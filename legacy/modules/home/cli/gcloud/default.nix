{
  config,
  pkgs,
  lib,
  ...
}:

{
  options = {
    cli.gcloud.enable = lib.mkEnableOption "enables google-cloud-sdk CLI";
  };

  config = lib.mkIf config.cli.gcloud.enable {
    home.packages = with pkgs; [
      google-cloud-sdk
    ];
  };
}
