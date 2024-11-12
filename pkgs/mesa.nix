{pkgs, ...}: let
  new_mesa = pkgs.mesa.overrideAttrs (oldAttrs: rec {
    mesonFlags =
      oldAttrs.mesonFlags
      ++ [
        (lib.mesonEnable "gallium-va" true)
        (lib.mesonEnable "microsoft-clc" true)
      ];
  });
in
  new_mesa