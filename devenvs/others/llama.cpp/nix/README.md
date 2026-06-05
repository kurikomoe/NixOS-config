# llama.cpp CUDA build with Nix

This flake provides a local CUDA environment for manual CMake builds and a Nix
package build.

## Development shell

From the repository root:

```sh
nix develop ./nix
cmake -S . -B build-cuda-native -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DGGML_CUDA=ON \
  -DGGML_NATIVE=ON \
  -DCMAKE_CUDA_ARCHITECTURES=86-real \
  -DGGML_CUDA_NCCL=OFF \
  -DLLAMA_OPENSSL=ON \
  -DOPENSSL_ROOT_DIR="$OPENSSL_ROOT_DIR" \
  -DCMAKE_CUDA_HOST_COMPILER="$CUDAHOSTCXX"
cmake --build build-cuda-native -j"$(nproc)"
```

`cuda_cudart` is included so `cuda_runtime.h` is available to `nvcc`.
`libcublas` is included for `CUDA::cublas`.
`openssl` is included so `llama-server -hf https://...` and Hugging Face HTTPS
downloads are enabled.
The shell uses `cudaPackages.backendStdenv` so `nvcc` gets a CUDA-supported
GCC host compiler instead of the latest nixpkgs default GCC.
The shell also sets `NIX_ENFORCE_NO_NATIVE=0`, allowing `-march=native` and
other native CPU flags through Nix's compiler wrapper.
CUDA is configured for `86-real`, which targets RTX 3090 / Ampere GA102 only.
For WSL2, the shell keeps the existing `LD_LIBRARY_PATH` first and appends Nix
CUDA libraries, so paths such as `/usr/lib/wsl/lib` take precedence:

```sh
printf '%s\n' "$LD_LIBRARY_PATH" | tr ':' '\n'
```

If you previously configured another build directory with the wrong compiler,
delete that directory or use a fresh `-B` path. CMake caches compiler choices.
The same applies if the directory was configured before OpenSSL was available.

## Package build

```sh
nix build ./nix#cuda
nix build ./nix#cuda-native
```

`.#cuda` uses portable CPU flags. `.#cuda-native` enables `GGML_NATIVE=ON` and
sets `NIX_ENFORCE_NO_NATIVE=0`. Both disable NCCL by default to keep the
essential CUDA dependency set small.
