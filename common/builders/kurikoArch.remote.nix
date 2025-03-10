{config, ...}: let
  username = "kuriko";

  hostName = "kurikoArch.remote";
  hostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPJuY6OLjTZ4/eWaaW8HKZrBhg+zX0Y+xo+4SMJQp05s";

  keyFile = "/etc/ssh/ssh_host_ed25519_key";

  hostTag = "bs.${hostName}";
in {
  config.age.secrets."builders/kurikoArch.ssh".mode = "444";

  config.programs.ssh.extraConfig = ''
    Host ${hostTag}
      include ${config.age.secrets."builders/kurikoArch.ssh".path}
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
        speedFactor = 1;
        supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
      }
    ];
  };
}
