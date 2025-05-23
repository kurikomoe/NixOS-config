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
    enable = true;
    package = vscode-fhs;
    profiles = {
      default = {
        inherit (deps) extensions;
        enableExtensionUpdateCheck = true;
        enableUpdateCheck = true;
      };
    };
  };
}
