{
  repos,
  inputs,
  ...
}: let
  pkgs = repos.pkgs-unstable;

  deps = pkgs.callPackage ./plugins.nix {pkgs = repos.pkgs-unstable;};

  # Alternative
  vscodeWithExtensions = pkgs.vscode-with-extensions.override {
    vscodeExtensions = deps.extensions;
  };

  vscode-fhs = pkgs.vscode.fhsWithPackages (ps: with ps; [] ++ deps.libs);
in {
  home.packages = with pkgs; [];

  programs.vscode = {
    inherit (deps) extensions;
    package = vscode-fhs;
    enable = true;
    enableUpdateCheck = true;
    enableExtensionUpdateCheck = true;
  };
}
