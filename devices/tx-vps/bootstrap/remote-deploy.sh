#!/usr/bin/env bash

TARGET=$1

if [[ $1 == "" ]]; then
  echo "./remote-deploy.sh <HOST>"
  exit 1
fi

nix run github:nix-community/nixos-anywhere  -- \
  --flake .#bootstrap \
  --target-host $TARGET \
  --generate-hardware-config nixos-generate-config ./hardware-configuration.nix \
  --build-on-remote
