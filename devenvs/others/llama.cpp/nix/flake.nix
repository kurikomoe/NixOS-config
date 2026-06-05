{
  description = "CUDA development flake for llama.cpp";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    llama-src = {
      url = "path:..";
      flake = false;
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://cuda-maintainers.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs = inputs @ {
    flake-parts,
    llama-src,
    nixpkgs,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];

      perSystem = {system, ...}: let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            cudaSupport = true;
          };
        };

        inherit (pkgs) lib;
        cuda = pkgs.cudaPackages;
        cudaStdenv = cuda.backendStdenv;
        cudaHostCc = cudaStdenv.cc;
        cudaArchitectures = ["86-real"]; # RTX 3090 / Ampere GA102.

        cudaBuildInputs = with cuda;
          [
            cuda_cccl
            cuda_cudart
            cuda_nvcc
            cuda_nvrtc
            cuda_nvtx
            libcublas
          ]
          ++ [
            pkgs.openssl
          ];

        cudaNativeBuildInputs = with pkgs; [
          cmake
          git
          makeWrapper
          ninja
          pkg-config
        ];

        cudaLibraryPath = lib.makeLibraryPath (
          cudaBuildInputs
          ++ [
            pkgs.linuxPackages.nvidia_x11
          ]
        );

        cudaIncludeFlags = lib.concatMapStringsSep " " (pkg: "-I${lib.getDev pkg}/include") [
          cuda.cuda_cccl
          cuda.cuda_cudart
          cuda.cuda_nvrtc
          cuda.cuda_nvtx
          cuda.libcublas
        ];

        commonCmakeFlags = native: [
          "-DGGML_CUDA=ON"
          "-DGGML_NATIVE=${
            if native
            then "ON"
            else "OFF"
          }"
          "-DGGML_CUDA_NCCL=OFF"
          "-DLLAMA_OPENSSL=ON"
          "-DOPENSSL_ROOT_DIR=${pkgs.openssl.dev}"
          "-DLLAMA_BUILD_TESTS=OFF"
          "-DCMAKE_CUDA_ARCHITECTURES=${lib.concatStringsSep ";" cudaArchitectures}"
          "-DCMAKE_CUDA_FLAGS=${cudaIncludeFlags}"
          "-DCMAKE_C_COMPILER=${cudaHostCc}/bin/gcc"
          "-DCMAKE_CXX_COMPILER=${cudaHostCc}/bin/g++"
          "-DCMAKE_CUDA_HOST_COMPILER=${cudaHostCc}/bin/c++"
        ];

        llamaCudaPackage = {native ? false}:
          cudaStdenv.mkDerivation ({
              pname = "llama-cpp-cuda${lib.optionalString native "-native"}";
              version = "0.0.0";
              src = llama-src;

              nativeBuildInputs =
                cudaNativeBuildInputs
                ++ [
                  cuda.cuda_nvcc
                ];
              buildInputs = cudaBuildInputs;

              cmakeFlags = commonCmakeFlags native;

              postFixup = ''
                for program in "$out"/bin/*; do
                  if [ -x "$program" ]; then
                    wrapProgram "$program" --suffix LD_LIBRARY_PATH : ${cudaLibraryPath}
                  fi
                done
              '';

              meta = {
                description = "llama.cpp built with CUDA support${lib.optionalString native " and native CPU optimizations"}";
                platforms = ["x86_64-linux"];
              };
            }
            // lib.optionalAttrs native {
              NIX_ENFORCE_NO_NATIVE = "0";
            });
      in {
        formatter = pkgs.nixfmt-rfc-style;

        packages = rec {
          default = llamaCudaPackage {};
          cuda = default;
          native = llamaCudaPackage {native = true;};
          "cuda-native" = native;
        };

        devShells.default = (pkgs.mkShell.override {stdenv = cudaStdenv;}) {
          hardeningDisable = ["all"];
          nativeBuildInputs = cudaNativeBuildInputs;
          buildInputs = cudaBuildInputs;

          CC = "${cudaHostCc}/bin/gcc";
          CXX = "${cudaHostCc}/bin/g++";
          CUDA_PATH = cuda.cuda_nvcc;
          CUDA_HOME = cuda.cuda_nvcc;
          CUDAToolkit_ROOT = cuda.cuda_nvcc;
          CUDACXX = "nvcc";
          CUDAFLAGS = cudaIncludeFlags;
          OPENSSL_ROOT_DIR = pkgs.openssl.dev;
          NIX_ENFORCE_NO_NATIVE = "0";

          shellHook = ''
            export CUDAHOSTCXX="${cudaHostCc}/bin/c++"
            export CMAKE_PREFIX_PATH="${lib.makeSearchPathOutput "dev" "" cudaBuildInputs}:$CMAKE_PREFIX_PATH"
            export NIX_CUDA_LIBRARY_PATH="${cudaLibraryPath}"
            export LD_LIBRARY_PATH="''${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}$NIX_CUDA_LIBRARY_PATH"
            echo "CUDA dev shell ready."
            echo "LD_LIBRARY_PATH keeps the pre-existing environment before Nix CUDA paths."
            echo "Configure: cmake -S . -B build-cuda-native -G Ninja -DCMAKE_BUILD_TYPE=Release -DGGML_CUDA=ON -DGGML_NATIVE=ON -DCMAKE_CUDA_ARCHITECTURES=${lib.concatStringsSep ";" cudaArchitectures} -DGGML_CUDA_NCCL=OFF -DLLAMA_OPENSSL=ON -DOPENSSL_ROOT_DIR=${pkgs.openssl.dev} -DCMAKE_CUDA_HOST_COMPILER=$CUDAHOSTCXX"
            echo "Build:     cmake --build build-cuda-native -j$NIX_BUILD_CORES"
          '';
        };
      };
    };
}
