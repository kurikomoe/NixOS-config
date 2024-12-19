let
  key_age = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK88u8wb/Zcxd8WQoBgcZANWzrgar0iYvOhvr5yGtbw0";

  system_tx = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPM25/UG2xBAdE679n4HzWfApH+0ezYKK0cEC+JicZcg";
  user_tx = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHYWa0plFvmQkJIHG15fkLqX6cjyg5pimMnnplGc2y7n";
  keys_tx = [system_tx user_tx];

  keys = [key_age] ++ keys_tx;

  file_list = {
    "res/gnupg" = {
      "private.pgp".publicKeys = [key_age];
      "public.pgp".publicKeys = [key_age];
    };

    "res/ssh" = {
      "config".publicKeys = [key_age];
      "config-iprc".publicKeys = [key_age];

      "id_rsa".publicKeys = [key_age];
      "id_rsa.pub".publicKeys = keys;
      "id_ed25519".publicKeys = [key_age];
      "id_ed25519.pub".publicKeys = keys;
      "id_ed25519_age.pub".publicKeys = keys;
    };

    "res/gh" = {
      "hosts.yml".publicKeys = keys;
    };

    "res/nix" = {
      "access-tokens".publicKeys = keys;
      "cachix.nix.conf".publicKeys = keys;
    };

    "res/clash" = {
      "config.m.yaml".publicKeys = keys;
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
