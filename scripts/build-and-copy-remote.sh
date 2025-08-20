#!/usr/bin/env bash

set -ex

nix build .#homeConfigurations."$1".activationPackage
nix-store --export $(nix-store --query --requisites ./result) | gzip -c | ssh $2 'gzip -d  > $3'
