{ pkgs }:

{
  anthropicSkills = pkgs.fetchFromGitHub {
    owner = "anthropics";
    repo = "skills";
    rev = "0a64e398ec6bb34a494f0c347e8ccae53a862f8e";
    hash = "sha256-0ZtHTJVHeW8jIprKgCo/yU2ZI2cZxUqD3Riet3UWdt8=";
  };

  mattpocockSkills = pkgs.fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    rev = "885e2ca4d842d139e9aef4e48d366c63cb1b8013";
    hash = "sha256-BAhmwFuEZPKsnSCwZ9NzPG5b7alCXa2/f/LXSMuJX7o=";
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
