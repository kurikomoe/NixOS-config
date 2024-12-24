## Note

My WSL2+Nix/ArchLinux+Nix/deploy-rs + Standalone HomeManager + agenix(home-manager ver) Configs.

Secrets are encrypted by `id_ed25519_age` or VPS ssh_hostkey.

```shell
# please setup the wsl2-nixos first. (or any working nixos installation)
sudo nixos-rebuild --flake 'github:kurikomoe/nixos-config/main?dir=nixos#KurikoNixOS' test

# cp the `id_ed25519_age` to $HOME/.ssh/
home-manager --flake 'github:kurikomoe/nixos-config/main?dir=home-manager' switch --dry-run

# Or all-in-one
nixup # update the flakes and rebuild all
nixs  # only rebuild all
hms   # only rebuild home-manager, suitable for Nix+Arch.
```

# Deploy remote server (tencent cloud)
I prefer deploy-rs, which shares the same config as the `nixosConfiguration` or `homeManagerConfiguration`.
```shell
# nix-shell -p deploy-rs
# -s for disabling the syntax check.
deploy .#KurikoTXCloud [-s]
```

## Tips

Update the age files

```shell
cd home-manager/
# update the secrets.nix
agenix -p `file`
agenix-edit `file`
```
## Some Useful Links:
- [ThisCuteWorld](https://nixos-and-flakes.thiscute.world/zh/preface):  Nixos Tutorials For Beginners.
- [Nixpkgs Search](https://search.nixos.org/packages): Search the packages in Nixpkgs.
- [Nixos Options Search](https://search.nixos.org/options): Search the nixos options.
- [HomeManager Options Search](https://home-manager-options.extranix.com/): Search the home-manager options.
- [History Nixpkgs Search](https://www.nixhub.io/): Search the history version of specific pkg.
- [Nix builtins && Nixpkgs.lib Manual](https://noogle.dev/f/lib/mkDefault): Search the builtins && nixkpkgs.lib usages.
- [NixOS 打包从入门到入土](https://lantian.pub/article/modify-computer/nixos-packaging.lantian/): Very good tutorials on how to pack nix pkg.
