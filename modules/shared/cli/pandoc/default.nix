{
  config,
  pkgs,
  lib,
  ...
}:

let
  eisvogelTemplate = pkgs.fetchzip {
    url = "https://github.com/Wandmalfarbe/pandoc-latex-template/releases/download/v3.2.1/Eisvogel.zip";
    hash = "sha256-Yor6InuzWEXWzK06LBxksDfiqFfi1WK+s1j4pvByFog=";
  };

  academicDefaults = pkgs.writeText "academic-defaults.yaml" ''
    cite-method: biblatex
    embed-resources: true
    file-scope: false
    from: markdown
    highlight-style: pygments
    reference-location: block
    resource-path: []
    standalone: true
    top-level-division: default
    verbosity: ERROR
    pdf-engine: tectonic
    to: pdf
    variables:
      geometry: margin=1in
  '';
in

{
  home.packages = with pkgs; [

  ];

  programs.pandoc = {
    enable = true;
    templates = {
      "eisvogel.latex" = "${eisvogelTemplate}/eisvogel.latex";
      "eisvogel.beamer" = "${eisvogelTemplate}/eisvogel.beamer";
      "academic-defaults.yaml" = academicDefaults;
    };
  };
}
