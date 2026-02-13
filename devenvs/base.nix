{inputs, ...}: {
  perSystem = {
    config,
    lib,
    pkgs,
    system,
    ...
  }: let
    cfg = config.devShellBase;
    pkgs-kuriko-nur = inputs.kuriko-nur.legacyPackages.${system};

    inherit (pkgs-kuriko-nur) devshell-cache-tools precommit-trufflehog;

    my-python = pkgs.python313.withPackages (ps:
      with ps; [
        pyyaml
        pysocks
        venvShellHook
      ]);
  in {
    options.devShellBase = {
      hardeningDisable = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "List of hardening options to disable in the devShell";
      };
      python = lib.mkOption {
        type = lib.types.package;
        default = my-python;
        description = "Python interpreter to use in the devShell";
      };
      packages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
        description = "List of packages to include in the devShell";
      };
      shellHook = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = "Shell hook script";
      };
      libraries = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
        description = "Libraries to add to LD_LIBRARY_PATH";
      };
      env = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {};
        description = "Environment variables";
      };
      mkShellArgs = lib.mkOption {
        type = lib.types.attrs;
        default = {};
        description = "Extra arguments passed directly to mkShell";
      };
    };

    config = {
      # 基础包
      devShellBase.packages = with pkgs; [
        # tools
        devshell-cache-tools
        git
        just
        hello
        precommit-trufflehog

        # requirements
        pkg-config
        zlib.dev
        openssl.dev
        stdenv.cc.cc.lib

        autoconf
        gnumake
        ninja
        cmake
        xmake
        mold

        uv
        cfg.python
      ];

      # 基础 Hook
      devShellBase.shellHook = ''
        export ROOT=$(realpath $PWD)
        test -f .venv/bin/activate && source .venv/bin/activate
        # test -f "$ROOT/pyproject.toml" && uv sync
        echo "🚀 Base environment loaded."
      '';

      # 集成 Pre-commit (git-hooks.nix 会自动处理合并)
      pre-commit.settings.hooks = {
        shellcheck.enable = true;
        commitizen.enable = true;
        alejandra.enable = true;
        trufflehog = {
          enable = true;
          entry = lib.getExe precommit-trufflehog;
          stages = ["pre-push" "pre-commit"];
        };
        devshell = {
          enable = true;
          entry = lib.getExe devshell-cache-tools;
          stages = ["pre-push"];
          pass_filenames = false;
          always_run = true;
        };
        # Python
        isort.enable = true;
        pyright.enable = true;
        flake8.enable = true;
      };

      # 最终生成 devShell
      devShells.default = pkgs.mkShell ({
          hardeningDisable = cfg.hardeningDisable;

          packages = cfg.packages ++ config.pre-commit.settings.enabledPackages;

          shellHook = ''
            ${config.pre-commit.shellHook}
            ${cfg.shellHook}
          '';

          env =
            {
              LD_LIBRARY_PATH = lib.makeLibraryPath (["/usr/lib/wsl"] ++ cfg.libraries ++ cfg.packages);
            }
            // cfg.env;
        }
        // cfg.mkShellArgs);
    };
  };
}
