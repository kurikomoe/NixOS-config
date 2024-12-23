{pkgs, ...}: {
  home.packages = with pkgs; [
    frida-tools
  ];
}
