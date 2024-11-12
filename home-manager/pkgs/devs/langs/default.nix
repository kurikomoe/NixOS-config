p @ {
  pkgs,
  inputs,
  ...
}: let
in {
  imports = [
    ./c_cpp.nix
    ./rust.nix
    ./zig.nix

    ./python.nix
    ./julia.nix

    ./golang.nix

    ./dotnet.nix
    ./java.nix

    ./node.nix

    ./ruby.nix
    ./lua.nix
    ./perl.nix

    ./latex.nix
  ];
}
