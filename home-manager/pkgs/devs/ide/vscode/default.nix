{
  repos,
  inputs,
  ...
}: let
  pkgs = repos.pkgs-unstable;
  deps = pkgs.callPackage ./plugins.nix {inherit pkgs repos;};

  # Alternative
  vscode-fhs = pkgs.vscode.fhsWithPackages (ps: with ps; [] ++ deps.libs);
  # vscodeWithExtensions = pkgs.vscode-with-extensions.override {
  #   vscodeExtensions = deps.extensions;
  # };
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
