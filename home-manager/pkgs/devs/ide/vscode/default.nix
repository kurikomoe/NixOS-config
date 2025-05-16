{
  repos,
  inputs,
  ...
}: let
  pkgs = repos.pkgs-unstable;

  extensions = pkgs.callPackage ./plugins.nix {pkgs = repos.pkgs-unstable;};

  # Alternative
  vscodeWithExtensions = pkgs.vscode-with-extensions.override {
    vscodeExtensions = extensions;
  };
in {
  home.packages = with pkgs; [];

  programs.vscode = {
    inherit extensions;
    package = pkgs.vscode-fhs;
    enable = true;
    enableUpdateCheck = true;
    enableExtensionUpdateCheck = true;
  };
}
