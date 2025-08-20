{
  pkgs,
  inputs,
  ...
}: let
in {
  home.packages = with pkgs;
    [
      # Terminals
      wget
      wget2
      curl
      htop
      # nvtopPackages.full
      less
      tree
      which
      util-linux
      killall

      frp

      tldr

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

      # PDF
      qpdf # 无损切分 pdf，qpdf input.pdf --pages input.pdf 79-94 -- output_79_94.pdf
      pdf2svg
    ]
    ++ (with pkgs.unixtools; [
      # (lib.lowPrio xxd)
      (lib.lowPrio top)
      (lib.lowPrio col)
      (lib.lowPrio arp)
      (lib.lowPrio wall)
      (lib.lowPrio ping)
      (lib.lowPrio fsck)
      (lib.lowPrio write)
      (lib.lowPrio watch)
      (lib.lowPrio route)
      (lib.lowPrio quota)
      (lib.lowPrio fdisk)
      (lib.lowPrio script)
      (lib.lowPrio procps)
      (lib.lowPrio getopt)
      (lib.lowPrio column)
      (lib.lowPrio whereis)
      (lib.lowPrio netstat)
      (lib.lowPrio nettools)
      (lib.lowPrio ifconfig)
    ]);
}
