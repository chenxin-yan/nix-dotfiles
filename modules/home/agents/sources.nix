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
    rev = "c64fa7ecf658dc2a507a9192c7c6da61dc4d5960";
    hash = "sha256-xRw9FK8/9346bVKFlAvHcKLiZheJuhXqK548te068FM=";
  };

  raindropSkills = pkgs.fetchFromGitHub {
    owner = "raindrop-ai";
    repo = "skills";
    rev = "ff6ae59640e9a157bee35d89a6b4a5f466cfb763";
    hash = "sha256-oXeinTY0LP6h4kiKw9xveoehuzREng1YyYn149mbLNI=";
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
