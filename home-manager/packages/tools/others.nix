{ pkgs, inputs, ... }:

let

in {

  home.packages = with pkgs; [
    # Terminals
    aria2
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

    # media
    yt-dlp
    ffmpeg_7-full

    # netdisk
    rclone
    rsync

    # git
    git
    gh

    # network
    lsof
    iftop

    # diskio
    iotop

    # others
    macchina
    topgrade
  ];
}
