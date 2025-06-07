{
  pkgs,
  repos,
  ...
}: {
  packages = with pkgs; [
    p7zip
    autossh
    sshpass

    zssh

    repos.pkgs-kuriko-nur.trzsz-ssh
    repos.pkgs-kuriko-nur.trzsz

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
