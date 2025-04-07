let
  key_age = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK88u8wb/Zcxd8WQoBgcZANWzrgar0iYvOhvr5yGtbw0";
  keys_age = [key_age];

  keys_tx =
    keys_age
    ++ [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPM25/UG2xBAdE679n4HzWfApH+0ezYKK0cEC+JicZcg System"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHYWa0plFvmQkJIHG15fkLqX6cjyg5pimMnnplGc2y7n User"
    ];

  keys_kurikoG14 =
    keys_age
    ++ [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG/WB1rjs8Gqtxjn7gPpuXzQ0Lpfs5egSC/w161ifboo root@KurikoNixOS"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMnof+7ZAzn6hRmqOTxEuEL+719RRWJonVEG2rWx0r2V root@KurikoTB16P"
    ];

  keys_cpuserver58 =
    keys_age
    ++ [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIKjZNEcnjScSSkCiWYmD2q5dRT6tw77gnuOs7cUudF7"
    ];

  keys = keys_age ++ keys_tx ++ keys_kurikoG14 ++ keys_cpuserver58;

  file_list = {
    "res/gnupg" = {
      "private.pgp".publicKeys = keys_age ++ keys_cpuserver58;
      "public.pgp".publicKeys = keys_age ++ keys_cpuserver58;
    };

    "res/ssh" = {
      "config".publicKeys = keys_age;
      "config-iprc".publicKeys = keys_age;

      "id_rsa".publicKeys = keys_age;
      "id_rsa.pub".publicKeys = keys;
      "id_ed25519".publicKeys = keys_age ++ keys_cpuserver58;
      "id_ed25519.pub".publicKeys = keys ++ keys_cpuserver58;
      "id_ed25519_age.pub".publicKeys = keys;
    };

    "res/frp" = {
      "frps.toml".publicKeys = keys_tx;
      "frpc-arch.toml".publicKeys = keys_age;
    };

    "res/gh" = {
      "hosts.yml".publicKeys = keys ++ keys_cpuserver58;
    };

    "res/nix" = {
      "access-tokens".publicKeys = keys ++ keys_cpuserver58;
      "cachix.nix.conf".publicKeys = keys ++ keys_cpuserver58;
    };

    "res/cachix" = {
      "cachix.dhall".publicKeys = keys;
    };

    "res/docker" = {
      "config.json".publicKeys = keys;
    };

    "res/clash" = {
      "config.m.yaml".publicKeys = keys;
    };

    "res/atuin" = {
      "key".publicKeys = keys ++ keys_cpuserver58;
    };

    "res/scripts" = {
      "c-desk.sh".publicKeys = keys_age;
    };

    "res/builders" = {
      "kurikoArch.ssh".publicKeys = keys;
    };
  };

  flattenAttrsWithAge = attrs:
    builtins.foldl' (
      acc: outerKey: let
        outerAttrs = builtins.getAttr outerKey attrs;
      in
        builtins.foldl' (
          innerAcc: innerKey: let
            innerValue = builtins.getAttr innerKey outerAttrs;
            newKey = "${outerKey}/${innerKey}.age";
          in
            innerAcc
            // {
              "${newKey}" = innerValue;
            }
        )
        acc (builtins.attrNames outerAttrs)
    ) {} (builtins.attrNames attrs);

  results = flattenAttrsWithAge file_list;
in
  results
