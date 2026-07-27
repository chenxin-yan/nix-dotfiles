{ pkgs }:

{
  anthropicSkills = pkgs.fetchFromGitHub {
    owner = "anthropics";
    repo = "skills";
    rev = "b29e7cf65e5cb78a5ac33d582270551bc74a14eb";
    hash = "sha256-RH2B03gj4kzw1j5LORezgUZPPu8mW+mWb+Kl2U7WUbY=";
  };

  mattpocockSkills = pkgs.fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    rev = "ed37663cc5fbef691ddfecd080dff42f7e7e350d";
    hash = "sha256-o/H9s3t6ahBqFwpkOMBOTwpsvb33pgvpI9n0PA+uLYM=";
  };

  raindropSkills = pkgs.fetchFromGitHub {
    owner = "raindrop-ai";
    repo = "skills";
    rev = "ed9ffb3307fa183aaa33fdabfea8524e20d6bd72";
    hash = "sha256-A4WZ+ho+G2G4PFZQjBVU1l+csXh3h1UvSOS91oVnBDU=";
  };

  raindropWorkshop = pkgs.fetchFromGitHub {
    owner = "raindrop-ai";
    repo = "workshop";
    rev = "8aa2d336dc8f9481a8b83a49a3a0c1aec3925fb1";
    hash = "sha256-kJcy5Kj+nwROdA73X8AHSPw59XVRQ04UF1/5LS35+3g=";
  };

  ponytail = pkgs.fetchFromGitHub {
    owner = "DietrichGebert";
    repo = "ponytail";
    rev = "16f29800fd2681bdf24f3eb4ccffe38be3baec6b";
    hash = "sha256-Y7d4s7uqjH6IbEXhqAiQ+yaxr6iiGcv2X64LuMtG1T8=";
  };
}
