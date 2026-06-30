{ pkgs }:

{
  anthropicSkills = pkgs.fetchFromGitHub {
    owner = "anthropics";
    repo = "skills";
    rev = "c30d329f5814647c1e2f071020c1e8c1c9893ef1";
    hash = "sha256-szcnow0yO1ViQt6Mxrd+PNdfZ5jzPqqSmqA0jEQnS1o=";
  };

  mattpocockSkills = pkgs.fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    rev = "0877403d1e867fd9d574117e9b34ade404f36d2a";
    hash = "sha256-2+2WR5Soqx4g7/T2YiOFj4XMGT5jGjnzOJlQ5ybCRS8=";
  };

  raindropSkills = pkgs.fetchFromGitHub {
    owner = "raindrop-ai";
    repo = "skills";
    rev = "be01a9ef3bd1db5b00919d5f7198678b6969d025";
    hash = "sha256-30BPbwFJf8m9V/fIoCmJ+aa5z6jNGubtTlYhqhijBLQ=";
  };

  raindropWorkshop = pkgs.fetchFromGitHub {
    owner = "raindrop-ai";
    repo = "workshop";
    rev = "914d74dc2c5dbfc13fa19ab9eb9bae0ecd48939e";
    hash = "sha256-7X41HYzcGpe/Z9l80ZrwYIJAaaYaig1Jf4Pj5xmbj+M=";
  };

  ponytail = pkgs.fetchFromGitHub {
    owner = "DietrichGebert";
    repo = "ponytail";
    rev = "0882e2d256fd953c6a3e90b946f68ce4f9f35153";
    hash = "sha256-+cWfki10COPyTXG6E095IvSVBr/PLXDqyzycwW4n5Xc=";
  };
}
