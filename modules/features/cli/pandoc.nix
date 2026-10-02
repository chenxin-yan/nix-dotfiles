{
  features.pandoc.homeManager =
    { pkgs, ... }:
    let
      eisvogel = pkgs.fetchFromGitHub {
        owner = "Wandmalfarbe";
        repo = "pandoc-latex-template";
        rev = "93cc5b8e08c658da012d7609491ae72b1aff72fc";
        hash = "sha256-bFN+w26kBC+yE30dljzpBt+81iQb3NkKuAUcHVGoFTU=";
      };

      # Eisvogel >= 3.5 loads the `sourcesans` LaTeX package, which is missing
      # from tectonic's frozen TeX Live 2022 bundle (and nixpkgs' TL 2025).
      # Under XeTeX it only needs the .sty plus the OTFs, so the eisvogel
      # defaults add them to tectonic's search path. Drop once tectonic's
      # bundle ships it.
      sourcesans = pkgs.fetchFromGitLab {
        owner = "slxh/latex";
        repo = "sourcesans";
        rev = "88c6d25588a1138f360d905bb1c4ee461daaef91";
        hash = "sha256-iOsvNTFFzPvh1lNHBd3UrhWgjI6Xut35ZZNj0XEqlBk=";
      };

      academicDefaults = pkgs.writeText "academic.yaml" (
        builtins.toJSON {
          cite-method = "biblatex";
          embed-resources = true;
          file-scope = false;
          from = "markdown";
          highlight-style = "pygments";
          reference-location = "block";
          resource-path = [ ];
          standalone = true;
          top-level-division = "default";
          verbosity = "ERROR";
          pdf-engine = "tectonic";
          to = "pdf";
          variables = {
            geometry = "margin=1in";
          };
        }
      );

      eisvogelDefaults = pkgs.writeText "eisvogel.yaml" (
        builtins.toJSON {
          template = "eisvogel.latex";
          pdf-engine = "tectonic";
          pdf-engine-opts = [
            "-Zsearch-path=${sourcesans}/tex/latex/sourcesans"
            "-Zsearch-path=${sourcesans}/fonts/opentype/adobe/sourcesans"
          ];
        }
      );
    in
    {
      home.packages = with pkgs; [
        tectonic
      ];

      programs.pandoc.enable = true;

      xdg.dataFile = {
        "pandoc/templates" = {
          source = "${eisvogel}/template-multi-file";
          recursive = true;
        };
        "pandoc/defaults/academic.yaml".source = academicDefaults;
        "pandoc/defaults/eisvogel.yaml".source = eisvogelDefaults;
      };
    };
}
