{
  pkgs,
  root,
  ...
}: let
in {
  home.packages = with pkgs; [
    openssh
    mosh
  ];

  age.secrets."scripts/c-desk.sh" = {
    file = "${root.base}/res/scripts/c-desk.sh.age";
    path = ".ssh/scripts/c-desk";
    symlink = false;
    mode = "700";
  };

  home.sessionPath = [
    ".ssh/scripts"
  ];
}
