#!/usr/bin/env bash

TARGET=$1

if [[ $TARGET == "" ]]; then
  echo "Invalid Target"
  exit 1
fi

nix run github:nix-community/nixos-anywhere -- \
  --generate-hardware-config nixos-generate-config ./hardware-configuration.nix \
  --flake .#bootstrap \
  --target-host root@$TARGET
  # --build-on-remote \

