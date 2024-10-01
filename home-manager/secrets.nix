let
  key_age = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK88u8wb/Zcxd8WQoBgcZANWzrgar0iYvOhvr5yGtbw0";
  keys = [ key_age ];

  file_list = {
    "res/gnupg" = [
      "private.pgp"
      "public.pgp"
    ];

    "res/ssh" = [
      "config"
      "id_rsa"
      "id_rsa.pub"
      "id_ed25519"
      "id_ed25519.pub"
      "id_ed25519_age.pub"
    ];

    "res/gh" = [
      "hosts.yml"
    ];

    "res/nix" = [
      "access-tokens"
    ];
  };

  # Credit to chatgpt 4o ...
  mapFiles = folder: files:
    # Create an attribute set where each file gets `.age` suffix
    builtins.listToAttrs (map (file: {
      name = "${folder}/${file}.age";
      value = { publicKeys = keys; };
    }) files);

  results = builtins.foldl' (acc: folder: acc // mapFiles folder (file_list.${folder})) {} (builtins.attrNames file_list);

in
  results
