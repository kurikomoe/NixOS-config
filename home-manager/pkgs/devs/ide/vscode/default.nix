{
  repos,
  inputs,
  ...
}: let
  pkgs = repos.pkgs-unstable;
  deps = pkgs.callPackage ./plugins.nix {inherit pkgs repos;};

  # Alternative
  vscode-fhs = pkgs.vscode.fhsWithPackages (ps: with ps; [] ++ deps.libs);
  vscodeWithExtensions =
    pkgs.vscode-with-extensions.override {
      vscode = vscode-fhs;
      vscodeExtensions = deps.extensions;
    }
    // {
      pname = pkgs.vscode.pname;
      version = pkgs.vscode.version;
    };
in {
  home.packages = with pkgs; [
    vscodeWithExtensions
  ];

  programs.vscode = {
    enable = true;
    package = vscodeWithExtensions;
    profiles = {
      default = {
        # inherit (deps) extensions;
        enableExtensionUpdateCheck = true;
        enableUpdateCheck = true;
      };
    };
  };
}
