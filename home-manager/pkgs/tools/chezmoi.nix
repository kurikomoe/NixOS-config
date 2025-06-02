{
  lib,
  pkgs,
  repos,
  root,
  customVars,
  ...
}: let
  inherit (repos.pkgs-unstable) chezmoi age;

  chezmoiRoot = "$HOME/.local/share/chezmoi";

  linkChezmoi = pkgs.writeShellScript "linkChezmoi" ''
    target="${chezmoiRoot}"
    source="$HOME/.nixos/chezmoi"
    # 依赖 coreutils 提供的 readlink 和 ln
    if [ -e "$target" ] && [ ! "$(${pkgs.coreutils}/bin/readlink -f "$target")" = "$(${pkgs.coreutils}/bin/readlink -f "$source")" ]; then
      rm -rf "$target"
    fi
    ${pkgs.coreutils}/bin/ln -sfT "$source" "$target"
  '';
in {
  home.packages = [
    chezmoi
    age
  ];

  home.shellAliases = {
    chz = "chezmoi";
  };

  home.activation.chezmoiMount = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run ${linkChezmoi}
    # run echo "devices/${customVars.hostName}" > "${chezmoiRoot}/.chezmoiroot"
    run ${chezmoi}/bin/chezmoi apply
  '';
}
