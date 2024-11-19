{ pkgs, ... }:

let

in {
  home.packages = with pkgs; [
    acpica-tools  # acpidump
    mkvtoolnix    # dump mkv embl info

    speedtest-cli  # speedtest
  ];
}
