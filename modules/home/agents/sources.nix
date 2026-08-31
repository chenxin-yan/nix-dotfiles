{ pkgs }:

{
  anthropicSkills = pkgs.fetchFromGitHub {
    owner = "anthropics";
    repo = "skills";
    rev = "3b3fad96af16a10759d930941b4520ba0c40edae";
    hash = "sha256-nVid8vENmLDh7ffDqh+bJbEWtXcVltA0qa2rItmniZM=";
  };

  mattpocockSkills = pkgs.fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    rev = "6654f6b60cd9d5be8b54c6fafe44346dabeb3b76";
    hash = "sha256-N5tpUIHO2VFeJntBTl6/VLDIVpqoshwFxNJlfXXUwsQ=";
  };

  pstack = pkgs.fetchFromGitHub {
    owner = "backnotprop";
    repo = "pstack";
    rev = "18e0e908a13553b0e58d065ab26dbc9a972ec8ba";
    hash = "sha256-NRg2kDFSV1O6v9YgHkYx2Yv8dZDs7pdQXPuyqXaGSNo=";
  };

  ponytail = pkgs.fetchFromGitHub {
    owner = "DietrichGebert";
    repo = "ponytail";
    rev = "2ed6c52c9d7e5e56942508591085fd45dea277d3";
    hash = "sha256-bGdXvzhWPwGdz3T2Yh2h6lf+3PBRFAfdBxP5pESmCHI=";
  };
}
