{ pkgs, inputs, ... }:

let

in {

  home.packages = with pkgs; [
    # Terminals
    wget
    curl
    htop
    less
    tree
    which
    util-linux
    killall

    glances
    gtop
    dust     # du-dust
    fd       # find
    fend
    ripgrep  # search tools
    file

    ncdu
    jq
    dos2unix

    asciinema # record terminal

    # network
    dig
    lsof
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
    topgrade

    # provide lddtree command for better ldd experience
    pax-utils
  ];
}
