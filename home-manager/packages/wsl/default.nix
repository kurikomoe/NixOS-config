p@{ config, lib, customVars, ... }:

let
  buildSymlinkSrc = config.lib.file.mkOutOfStoreSymlink;

  mkBinWinAbs = {name, src, isExecutable ? false}: {
    "/home/${customVars.username}/.local/bin.win/${name}" = {
      source = buildSymlinkSrc src;
      executable = isExecutable;
    };
  };

  mkBinWinRel = {name, src, isExecutable ? false}: {
    "/home/${customVars.username}/.local/bin.win/${name}" = {
      source = buildSymlinkSrc ./${src};
      executable = isExecutable;
    };
  };

  file_list = {
    "home/Downloads".source = buildSymlinkSrc /mnt/c/Users/Kuriko/Downloads;
  }
    # folders
    // (mkBinWinAbs { name = "shims_dir"; src = "/mnt/c/Users/Kuriko/scoop/shims"; })
    // (mkBinWinAbs { name = "cargo_dir"; src = "/mnt/w/@Packages/cargo/bin"; })
    # files
    // (mkBinWinAbs { name = "explorer.exe"; src = "/mnt/c/Windows/explorer.exe"; })
    // (mkBinWinRel { name = "explorer"; src = "explorer.exe"; })
    // (mkBinWinAbs { name = "clip.exe"; src = "/mnt/c/Windows/System32/clip.exe"; })
    // (mkBinWinAbs { name = "typora"; src = "/mnt/c/Windows/System32/clip.exe"; })
    // (mkBinWinAbs { name = "wsl.exe"; src = "/mnt/c/Windows/System32/wsl.exe"; })
    // (mkBinWinRel { name = "pwsh.exe"; src = "shims_dir/pwsh.exe"; })
    // (mkBinWinRel { name = "pwsh"; src = "pwsh.exe"; })
    // (mkBinWinRel { name = "git.exe"; src = "shims_dir/git.exe"; })
  ;
in {
  home.file = file_list // {
    ".local/bin/mount-all" = {
      source = ./mount-all;
      executable = true;
    };
  };

  home.shellAliases = {
    fopen = "explorer.exe";
  };

  home.sessionPath = [
    "$HOME/.local/bin.win"
  ];
}
