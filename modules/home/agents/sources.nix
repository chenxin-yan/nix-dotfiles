{ pkgs }:

{
  anthropicSkills = pkgs.fetchFromGitHub {
    owner = "anthropics";
    repo = "skills";
    rev = "f6656c1256d5a8adfa37db9110046ef20bac644c";
    hash = "sha256-5/0f5AnGWX3oM+M9Xm/zSmooz11+S1YRdFPmAX+DXi0=";
  };

  mattpocockSkills = pkgs.fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    rev = "bb1c760d559872044e76d18216c87165fa69908a";
    hash = "sha256-wp/zC1c/0CEDd28+LRyLMozaURnLKWvlN9GunLM99IY=";
  };

  ponytail = pkgs.fetchFromGitHub {
    owner = "DietrichGebert";
    repo = "ponytail";
    rev = "2ed6c52c9d7e5e56942508591085fd45dea277d3";
    hash = "sha256-bGdXvzhWPwGdz3T2Yh2h6lf+3PBRFAfdBxP5pESmCHI=";
  };
}
