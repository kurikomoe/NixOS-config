## Note

WSL2 + NixOS + Standalone HomeManager + agenix(home-manager ver)

Before build home-manager, you need to provide the `id_ed25519_age` rsa key for `agenix` to decrypt the `res/**/*.age` files

```shell
# please setup the wsl2-nixos first. (or any working nixos installation)

sudo nixos-rebuild --flake 'github:kurikomoe/nixos-config/main?dir=nixos#KurikoNixOS' test

# cp the `id_ed25519_age` to $HOME/.ssh/
home-manager --flake 'github:kurikomoe/nixos-config/main?dir=home-manager' switch --dry-run
```

# Usage

Update the age files

```shell
cd home-manager/
# update the secrets.nix
agenix -p `file`
```

