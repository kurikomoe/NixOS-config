{
  description = "Kuriko's Python Template";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    fenix.url = "github:nix-community/fenix";

    git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.inputs.nixpkgs.follows = "nixpkgs";

    kuriko-main.url = "github:kurikomoe/NixOS-config/main?dir=devenvs";
    kuriko-nur.url = "github:kurikomoe/nur-packages";
    kuriko-nur.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    substituters = [
      "https://cache.nixos.org"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://nix-community.cachix.org"
      "https://kurikomoe.cachix.org"
      "https://nix-cache.0v0.io/r2"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "kurikomoe.cachix.org-1:NewppX3NeGxT8OwdwABq+Av7gjOum55dTAG9oG7YeEI="
      "r2:p04JD2QTSWn937oqqCMX9CdMAd71ulb1FZZm+3Nd/9c="
    ];
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.git-hooks.flakeModule
        inputs.kuriko-main.flakeModules.devShellBase
      ];

      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];

      perSystem = {
        config,
        self',
        inputs',
        system,
        lib,
        ...
      }: let
        pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [];
        };
        inherit (pkgs) lib;
        pkgs-kuriko-nur = inputs.kuriko-nur.legacyPackages.${system};

        my-python-packages = pkgs.python313Packages;
        my-python = pkgs.python313.withPackages (ps:
          with ps; [
            pyyaml
            pysocks
            venvShellHook
          ]);
      in rec {
        formatter = pkgs.alejandra;

        devShellBase = let
        in {
          # hardeningDisable = ["all"];
          packages = with pkgs; [];
          python = my-python;

          # pip 装出来的二进制 wheel（numpy / torch / triton）依赖 "系统" 的
          # libstdc++.so.6、libgcc_s.so.1，而 WSL 这种精简 rootfs（没装 g++）
          # 里根本没有这两个库，import numpy 会直接失败。
          #
          # 这里列出的库会被 devShellBase 同时放进 mkShell 的 buildInputs
          #（提供 -L/-rpath）和 LD_LIBRARY_PATH（提供运行期查找），
          # 所以不用自己手写 LD_LIBRARY_PATH。
          #
          # 注：zlib(libz.so.1) / openssl / python 已经由 devShellBase 的默认
          # libraries 提供，这里只补缺失的 libstdc++。
          libraries = [
            config.devShellBase.stdenv.cc.cc.lib # libstdc++.so.6 + libgcc_s.so.1
          ];

          shellHook = ''
            # ---- CUDA / triton ----
            # triton 的 nvidia backend（triton/backends/nvidia/driver.py）会执行
            # `/sbin/ldconfig -p` 去定位 libcuda.so.1。WSL 的 rootfs 里没有
            # ldconfig，于是直接抛 FileNotFoundError。
            # triton >= 3.3 支持用 TRITON_LIBCUDA_PATH 显式指定驱动 stub 目录，
            # 命中后就不再走 ldconfig。
            if [ -z "''${TRITON_LIBCUDA_PATH-}" ]; then
              for _cuda_dir in /usr/lib/wsl/lib /usr/local/cuda/lib64 /usr/lib64; do
                if [ -e "$_cuda_dir/libcuda.so.1" ]; then
                  export TRITON_LIBCUDA_PATH="$_cuda_dir"
                  break
                fi
              done
              unset _cuda_dir
            fi

            # triton 运行期会用 gcc 现场编译 kernel launcher，并需要
            # libcuda.so（无版本号的那个）来 -lcuda，WSL 的驱动目录里有。
            if [ -n "''${TRITON_LIBCUDA_PATH-}" ]; then
              case ":''${LD_LIBRARY_PATH-}:" in
                *":$TRITON_LIBCUDA_PATH:"*) ;;
                *) export LD_LIBRARY_PATH="$TRITON_LIBCUDA_PATH:''${LD_LIBRARY_PATH-}" ;;
              esac
            fi
          '';

          env = rec {};
        };

        pre-commit.settings.hooks = {};
      };
    };
}
