{ pkgs }:

{
  anthropicSkills = pkgs.fetchFromGitHub {
    owner = "anthropics";
    repo = "skills";
    rev = "fa0fa64bdc967915dc8399e803be67759e1e62b8";
    hash = "sha256-QZ+zJkyLd/42rxgtJEZSUOz9R75Tse6UXW7G0nOkFS8=";
  };

  mattpocockSkills = pkgs.fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    rev = "9603c1cc8118d08bc1b3bf34cf714f62178dea3b";
    hash = "sha256-S6pARK99oGGSi6XdFm6zYKHT4gjOCN0wIPZFcl1hREE=";
  };

  raindropSkills = pkgs.fetchFromGitHub {
    owner = "raindrop-ai";
    repo = "skills";
    rev = "7d80323c7ae0938fa6eb0c0c88f819a4da6e6ed8";
    hash = "sha256-eJ4lVBhdoRblii7B/O4SqomvPAgqCmMJHinnxOooHVU=";
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
    rev = "16f29800fd2681bdf24f3eb4ccffe38be3baec6b";
    hash = "sha256-Y7d4s7uqjH6IbEXhqAiQ+yaxr6iiGcv2X64LuMtG1T8=";
  };
}
