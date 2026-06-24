{
  pkgs,
  repos,
  lib,
  ...
}: let
  trzsz-ssh = repos.pkgs-kuriko-nur.trzsz-ssh;
  trzsz = repos.pkgs-kuriko-nur.trzsz;
in {
  home.packages = with pkgs; [
    p7zip
    autossh
    sshpass

    zssh

    trzsz-ssh
    trzsz

    # conflict with the mkpasswd
    # expect

    mosh
  ];

  services = {
    ssh-agent.enable = true;
  };

  programs = {
    ssh = {
      enable = true;
      enableDefaultConfig = false;
      # 26.05: Renamed from matchBlocks to settings
      settings = {
        "*" = {
          serverAliveInterval = 60;
          compression = true;
          addKeysToAgent = "yes";
          forwardAgent = true;
        };
        "github.com" = {
          hostname = "ssh.github.com";
          port = 443;
        };
      };
    };
  };

  home.activation.sshAuthorizedKeys = lib.hm.dag.entryAfter ["agenix" "writeBoundary"] ''
    # 使用绝对路径或内置环境确保基础命令可用
    run mkdir -p ''$HOME/.ssh
    run chmod 700 ''$HOME/.ssh

    shopt -s nullglob
    pub_files=(''$HOME/.ssh/*.pub)
    shopt -u nullglob

    if [ ''${#pub_files[@]} -gt 0 ]; then
      run touch ''$HOME/.ssh/authorized_keys
      run chmod 600 ''$HOME/.ssh/authorized_keys

      # 使用 pkgs.gawk 和 pkgs.coreutils 提供的绝对路径
      run ${pkgs.gawk}/bin/awk '!seen[''$0]++' ''$HOME/.ssh/authorized_keys "''${pub_files[@]}" | run ${pkgs.coreutils}/bin/tee ''$HOME/.ssh/authorized_keys.tmp > /dev/null
      run mv ''$HOME/.ssh/authorized_keys.tmp ''$HOME/.ssh/authorized_keys
    else
      echo "No .pub files found, skipping authorized_keys generation."
    fi
  '';
}
