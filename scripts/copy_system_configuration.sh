#!/usr/bin/env bash

set -ex

ROOT=$(dirname $0)

rsync -avP /etc/nixos/ "$ROOT/../nixos"
