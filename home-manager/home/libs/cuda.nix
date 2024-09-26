{ pkgs, inputs, repos, ... }:

let

in {
  nixpkgs.overlays = [
    (self: super: {
      cudaPackages.cudatoolkit = repos.cuda."12.2".cudaPackages.cudatoolkit;
    })
  ];

  home.packages = with pkgs; [
    (lib.hiPrio cudaPackages.cudatoolkit)
  ];
}
