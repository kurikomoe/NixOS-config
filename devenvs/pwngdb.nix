{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    pwndbg.url = "github:pwndbg/pwndbg";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      inputs = [
      ];

      perSystem = {
        inputs',
        pkgs,
        system,
        ...
      }: {
      };
    };
}
