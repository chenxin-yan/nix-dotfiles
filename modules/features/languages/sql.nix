let
  # TODO: remove this overlay once nixpkgs bumps python3Packages.diff-cover to
  # >= 10.6.0 and the locked nixpkgs includes it. Pygments 2.21 changed how it
  # escapes quotes in HTML, breaking diff-cover 10.5.1's HTML fixtures (fixed
  # upstream in https://github.com/Bachmann1234/diff_cover/pull/625). sqlfluff
  # depends on diff-cover. To check, delete the overlay and run:
  #   nix build .#darwinConfigurations.work-macbook.pkgs.sqlfluff
  diff-cover-overlay = final: prev: {
    pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
      (pyFinal: pyPrev: {
        diff-cover = pyPrev.diff-cover.overridePythonAttrs (old: {
          disabledTests = (old.disabledTests or [ ]) ++ [
            "test_added_file_pycodestyle_html"
            "test_added_file_pyflakes_html"
            "test_added_file_pylint_html"
            "test_all_reports"
            "test_fail_under_html"
            "test_fail_under_pass_html"
          ];
        });
      })
    ];
  };
in
{
  features.sql.darwin.nixpkgs.overlays = [ diff-cover-overlay ];
  features.sql.nixos.nixpkgs.overlays = [ diff-cover-overlay ];

  features.sql.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        sqlit-tui

        # editor
        sqlfluff
      ];

      xdg.configFile."sqlit/settings.json".text = builtins.toJSON {
        theme = "catppuccin-mocha";
      };
    };
}
