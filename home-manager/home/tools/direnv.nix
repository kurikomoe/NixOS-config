{ lib, nixpkgs, inputs, pkgs, repos, ... }:

{
  # use unstable direnv to bypass warning
  nixpkgs.overlays = [
    (self: super: {
      direnv = repos.pkgs-unstable.direnv;
      nix-direnv = repos.pkgs-unstable.nix-direnv;
    })
  ];

  programs = {
    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
