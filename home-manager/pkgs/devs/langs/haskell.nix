{pkgs, ...}: let
in {
  home.packages = with pkgs;
    [
    ]
    ++ (with pkgs.haskellPackages; [
      stack
    ]);
}
