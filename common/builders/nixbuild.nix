{config, ...}: let
  username = "root";

  hostName = "eu.nixbuild.net";
  hostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPJuY6OLjTZ4/eWaaW8HKZrBhg+zX0Y+xo+4SMJQp05s";

  keyFile = "/etc/ssh/ssh_host_ed25519_key";

  hostTag = "builder.${hostName}";
in {
  programs.ssh.extraConfig = ''
    Host ${hostTag}
      HostName ${hostName}
      User ${username}
      PubkeyAcceptedKeyTypes ssh-ed25519
      ServerAliveInterval 60
      IPQoS throughput
      IdentityFile /etc/ssh/ssh_host_ed25519_key
  '';

  programs.ssh.knownHosts = {
    ${hostTag} = {
      hostNames = [hostName];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIQCZc54poJ8vqawd8TraNryQeJnvH1eLpIDgbiqymM";
    };
  };

  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        protocol = "ssh-ng";
        hostName = hostTag;
        system = "x86_64-linux";
        maxJobs = 100;
        # supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
        supportedFeatures = ["benchmark" "big-parallel"];
      }
    ];
  };
}
