let
  key_age = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK88u8wb/Zcxd8WQoBgcZANWzrgar0iYvOhvr5yGtbw0";
  system_tx = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHYWa0plFvmQkJIHG15fkLqX6cjyg5pimMnnplGc2y7n";

  keys = [
    key_age
    system_tx
  ];

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
  };

  # Credit to chatgpt 4o ...
  # mapFiles = folder: files:
  # # Create an attribute set where each file gets `.age` suffix
  #   builtins.listToAttrs (map (file: {
  #       name = "${folder}/${file}.age";
  #       value = {publicKeys = keys;};
  #     })
  #     files);

  # results = builtins.foldl' (acc: folder: acc // mapFiles folder (file_list.${folder})) {} (builtins.attrNames file_list);

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
# {
#   "res/gnupg/private.pgp".publicKeys = [key_age];
#   "res/gnupg/public.pgp".publicKeys = [key_age];
#   "res/ssh/config".publicKeys = [key_age];
#   "res/ssh/config-iprc".publicKeys = [key_age];
#   "res/ssh/id_rsa".publicKeys = [key_age];
#   "res/ssh/id_ed25519".publicKeys = [key_age];
#   "res/ssh/id_rsa.pub".publicKeys = keys;
#   "res/ssh/id_ed25519.pub".publicKeys = keys;
#   "res/ssh/id_ed25519_age.pub".publicKeys = keys;
#   "res/gh/hosts.yml.age".publicKeys = keys;
#   "res/nix/access-tokens.age".publicKeys = keys;
#   "res/nix/cachix.nix.conf".publicKeys = keys;
# }

