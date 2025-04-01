{
  pkgs,
  input,
  ...
}: {
  home.packages = with pkgs; [
    # abseil-cpp
    # gtest
    # gflags

    # ocl-icd
    # opencl-headers
    # clinfo
  ];
}
