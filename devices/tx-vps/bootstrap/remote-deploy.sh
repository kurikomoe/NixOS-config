#!/usr/bin/env bash

TARGET=""

nix run ./nixos-anywhere  -- \
  --flake ../../..third/nixos-anywhere#bootstrap \
  --target-host $TARGET \
  --generate-hardware-config nixos-generate-config ./hardware-configuration.nix \
  --build-on-remote
