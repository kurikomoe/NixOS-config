{pkgs, ...}: let
  ghidra-combine = pkgs.ghidra.withExtensions (p:
    with p; [
      findcrypt
      machinelearning
      ghidraninja-ghidra-scripts
      ghidra-golanganalyzerextension
    ]);
in {
  home.packages = with pkgs; [
    # ghidra
    # ghidra-bin
    ghidra-combine
  ];
}
