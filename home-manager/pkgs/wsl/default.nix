{
  config,
  lib,
  pkgs,
  customVars,
  ...
} @ inputs: let
  buildSymlinkSrc = config.lib.file.mkOutOfStoreSymlink;

  mount-all = pkgs.writeShellScriptBin "mount-all" ''
    sudo true

    # wsl.exe -d NixOS --mount --vhd "W:/@Packages/WSL/LinuxProjects.vhdx" --bare
    # gsudo pwsh -c 'wsl.exe -d NixOS --mount --vhd "D:/Data/WSL/LinuxProjects.vhdx" --bare'
    # gsudo "$(wslupath $(realpath wsl.exe))" -d NixOS --mount --vhd "D:/Data/WSL/LinuxProjects.vhdx" --bare

    ProjectVhdx=/mnt/d/Data/WSL/LinuxProjects.vhdx
    [ -f "$ProjectVhdx" ] \
      && gsudo "$(wslpath -w $(realpath $(which wsl.exe)))" -d NixOS --mount \
        --vhd "$(wslpath -w $ProjectVhdx)" --bare \
      && echo Mount $ProjectVhdx

    ProjectVhdx=/mnt/w/@Data/WSL/LinuxProjects.vhdx
    [ -f "$ProjectVhdx" ] \
      && gsudo "$(wslpath -w $(realpath $(which wsl.exe)))" -d NixOS --mount \
        --vhd "$(wslpath -w $ProjectVhdx)" --bare \
      && echo Mount $ProjectVhdx

    sleep 1

    for i in `seq 1 10`; do
      sudo mount -a;
      if [[ $? == 0 ]]; then
        break
      fi
      sleep 1;
    done
  '';

  mkBinWinAbs = {
    name,
    src,
    isExecutable ? false,
  }: {
    "/home/${customVars.username}/.local/bin.win/${name}" = {
      source = buildSymlinkSrc src;
      executable = isExecutable;
    };
  };

  mkBinWinRel = {
    name,
    src,
    isExecutable ? false,
  }: {
    "${config.home.homeDirectory}/.local/bin.win/${name}" = {
      source = buildSymlinkSrc "${config.home.homeDirectory}/.local/bin.win/${src}";
      executable = isExecutable;
    };
  };

  file_list =
    {
      "Downloads".source = buildSymlinkSrc /mnt/c/Users/Kuriko/Downloads;
    }
    # folders
    // (mkBinWinAbs {
      name = "shims_dir";
      src = "/mnt/c/Users/Kuriko/scoop/shims";
    })
    // (mkBinWinAbs {
      name = "cargo_dir";
      src = "/mnt/w/@Packages/cargo/bin";
    })
    # files
    ## abs
    // (mkBinWinAbs {
      name = "explorer.exe";
      src = "/mnt/c/Windows/explorer.exe";
    })
    // (mkBinWinAbs {
      name = "clip.exe";
      src = "/mnt/c/Windows/System32/clip.exe";
    })
    // (mkBinWinAbs {
      name = "typora";
      src = "/mnt/c/Program Files/Typora/Typora.exe";
    })
    // (mkBinWinAbs {
      name = "wsl.exe";
      src = "/mnt/c/Windows/System32/wsl.exe";
    })
    // (mkBinWinRel {
      name = "wsl";
      src = "wsl.exe";
    })
    // (mkBinWinAbs {
      name = "code";
      src = "/mnt/c/Users/Kuriko/AppData/Local/Programs/Microsoft VS Code/bin/code";
    })
    ## rel
    // (mkBinWinRel {
      name = "explorer";
      src = "explorer.exe";
    })
    // (mkBinWinRel {
      name = "pwsh.exe";
      src = "shims_dir/pwsh.exe";
    })
    // (mkBinWinRel {
      name = "pwsh";
      src = "pwsh.exe";
    })
    // (mkBinWinRel {
      name = "gsudo.exe";
      src = "shims_dir/sudo.exe";
    })
    // (mkBinWinRel {
      name = "gsudo";
      src = "gsudo.exe";
    })
    // (mkBinWinRel {
      name = "nu.exe";
      src = "shims_dir/nu.exe";
    })
    // (mkBinWinRel {
      name = "nu";
      src = "nu.exe";
    })
    // (mkBinWinRel {
      name = "git.exe";
      src = "shims_dir/git.exe";
    })
    // (mkBinWinRel {
      name = "op.exe";
      src = "shims_dir/op.exe";
    })
    // (mkBinWinRel {
      name = "op";
      src = "op.exe";
    });
in {
  home.packages = with pkgs; [
    mount-all
    wslu
  ];

  home.file =
    file_list
    // {
      # ".local/bin/mount-all" = {
      #   source = ./mount-all;
      #   executable = true;
      # };
    };

  home.shellAliases = {
    fopen = "explorer.exe";
  };

  home.sessionPath = [
    "$HOME/.local/bin.win"
  ];
}
