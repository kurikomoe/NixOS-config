{
  pkgs,
  repos,
  ...
}: let
  go = repos.pkgs-unstable.go;

  trzsz-ssh = repos.pkgs-kuriko-nur.trzsz-ssh;
  trzsz = repos.pkgs-kuriko-nur.trzsz;
in {
  packages = with pkgs; [
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

  programs = {
    ssh = {
      enable = true;
      compression = true;
      addKeysToAgent = "yes";
      forwardAgent = true;
      serverAliveInterval = 60;
    };
  };
}
