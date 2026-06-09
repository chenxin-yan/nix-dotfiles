{
  pkgs,
  lib,
  config,
  ...
}:

{
  options = {
    dev.terraform.enable = lib.mkEnableOption "enables Terraform/OpenTofu development tools";
  };

  config = lib.mkIf config.dev.terraform.enable {
    home.packages = with pkgs; [
      opentofu
      tofu-ls
      tflint
    ];
  };
}
