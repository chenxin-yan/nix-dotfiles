{
  features.terraform.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        opentofu
        tofu-ls
        tflint
      ];
    };
}
