{
  features.wechat.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.wechat ];
    };
}
