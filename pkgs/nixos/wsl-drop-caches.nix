# https://github.com/arkane-systems/wsl-drop-caches
{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.services.wsl-drop-caches;

  pythonDep = pkgs.python3.withPackages (python-pkgs:
    with python-pkgs; [
      psutil
    ]);

  wsl-drop-caches = pkgs.stdenv.mkDerivation rec {
    pname = "wsl-drop-caches";
    version = "0.4";

    src = pkgs.fetchzip {
      url = "https://github.com/arkane-systems/wsl-drop-cache/releases/download/v${version}/wsl-drop-caches_${version}.tar.xz";
      sha256 = "sha256-Cn5xGXXkotxCgKhnkIgr5Dect+eOf6gr8SfPhnQT1Z0=";
    };

    phases = ["unpackPhase" "installPhase"];

    buildInputs = with pkgs; [pythonDep coreutils];

    installPhase = ''
      mkdir -p $out/bin;
      cp drop_cache_if_idle $out/bin;
      chmod +x $out/bin/drop_cache_if_idle;
    '';
  };
in {
  options.services.wsl-drop-caches = {
    enable = lib.mkEnableOption "wsl-drop-cache Periodically drop the WSL caches when load is low.";
    interval = lib.mkOption {
      default = "3min";
      type = lib.types.nullOr lib.types.str;
      example = "3min";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services."wsl-drop-caches" = {
      description = "Periodically drop caches to save memory under WSL.";
      documentation = ["https://github.com/arkane-systems/wsl-drop-cache"];
      # conditionVirtualization = "wsl";
      requires = ["wsl-drop-caches.timer"];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${wsl-drop-caches}/bin/drop_cache_if_idle";
        Environment = "PATH=${pkgs.coreutils}/bin:${pythonDep}/bin:$PATH";
      };
    };

    systemd.timers."wsl-drop-caches" = {
      description = "Periodically drop caches to save memory under WSL.";
      documentation = ["https://github.com/arkane-systems/wsl-drop-cache"];
      # conditionVirtualization = "wsl";
      partOf = ["wsl-drop-caches.service"];

      wantedBy = ["timers.target"];

      timerConfig = {
        OnBootSec = cfg.interval;
        OnUnitActiveSec = cfg.interval;
      };
    };
  };
}
