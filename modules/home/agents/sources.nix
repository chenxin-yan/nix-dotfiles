{ pkgs }:

{
  anthropicSkills = pkgs.fetchFromGitHub {
    owner = "anthropics";
    repo = "skills";
    rev = "41bbe19d1a1a7eaab5e7bb9050a417e5c6cffc8f";
    hash = "sha256-sjgPv9tZZVTXPxZWaCOc7JwFceNn3C1ghy8mSHqgqB8=";
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

  humanlayerSkills = pkgs.fetchFromGitHub {
    owner = "humanlayer";
    repo = "skills";
    rev = "3c2629142c5d437428269b1b722b08c0b87f574d";
    hash = "sha256-lJvu9CGAN/+dzmzck0CodRXn/p7GUkCbfyZxys4nIoU=";
  };
}
