#!/usr/bin/env bash

set -ex

ROOT=$(dirname $0)

sudo rsync -avP "$ROOT/../nixos/" /etc/nixos/ --delete
