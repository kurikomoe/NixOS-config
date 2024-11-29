{
  pkgs,
  inputs,
  ...
}: let
in {
  home.packages = with pkgs; [
    # Terminals
    wget
    curl
    htop
    nvtopPackages.full
    less
    tree
    which
    util-linux
    killall

    cowsay

    # hardwares
    pciutils
    usbutils
    ethtool
    parted
    gparted

    kmod

    glances
    gtop
    dust # du-dust
    fd # find
    fend
    ripgrep # search tools
    file
    mlocate

    libva-utils

    ncdu
    jq
    dos2unix

    asciinema # record terminal

    # network
    dig
    lsof
    lshw
    hwloc
    iftop
    nettools
    tcpdump
    traceroute
    mtr

    caddy
    aria2

    # media
    yt-dlp
    ffmpeg_7-full

    # netdisk
    rclone
    rsync

    # diskio
    iotop

    # others
    macchina
    fastfetch
    topgrade

    # task control
    just
    pueue

    # provide lddtree command for better ldd experience
    pax-utils

    # nix tools
    nix-output-monitor # aka nom
  ];
}
