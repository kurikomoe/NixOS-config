{ lib, nixpkgs, inputs, pkgs, repos, ... }:

{
  # use unstable direnv to bypass warning
  nixpkgs.overlays = [
    (self: super: {
      direnv = repos.pkgs-unstable.direnv;
      nix-direnv = repos.pkgs-unstable.nix-direnv;
    })
  ];

  home.packages = with pkgs; [
    devenv
  ];

  programs = {
    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
      nix-direnv.enable = true;
      config = {
        "global"."hide_env_diff" = true;
      };
    };
  };
}
