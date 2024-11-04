{ ... }:

{
  home.packages = with pkgs; [
    util-linux
    ltrace
    strace
  ];
}
