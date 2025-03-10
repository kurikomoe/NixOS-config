{config, ...}: let
  username = "kuriko";

  hostName = "192.168.3.100";
  hostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPJuY6OLjTZ4/eWaaW8HKZrBhg+zX0Y+xo+4SMJQp05s";

  keyFile = "/etc/ssh/ssh_host_ed25519_key";

  hostTag = "bs.kurikoArch";
in {
  config.programs.ssh.extraConfig = ''
    Host ${hostTag}
      HostName ${hostName}
      User ${username}
      PubkeyAcceptedKeyTypes ssh-ed25519
      ServerAliveInterval 60
      IPQoS throughput
      IdentityFile /etc/ssh/ssh_host_ed25519_key
  '';

  config.programs.ssh.knownHosts = {
    ${hostTag} = {
      hostNames = [hostName];
      publicKey = hostKey;
    };
  };

  config.nix.extraOptions = ''
    builders-use-substitutes = true
  '';

  config.nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        protocol = "ssh-ng";
        hostName = hostTag;
        system = "x86_64-linux";
        systems = ["x86_64-linux"];
        maxJobs = 100;
        speedFactor = 100;
        supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
      }
    ];
  };
}
