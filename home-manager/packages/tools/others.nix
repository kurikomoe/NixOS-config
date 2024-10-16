{ pkgs, inputs, ... }:

let

in {

  home.packages = with pkgs; [
    # Terminals
    wget
    curl
    htop
    tree
    which
    dust     # du-dust
    fd       # find
    fend
    ripgrep  # search tools
    file

    killall

    ncdu

    jq


    # network
    dig
    lsof
    iftop

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
