#!/usr/bin/env bash
# shellcheck disable=SC2016

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

# Patch btrfs-assistant-launcher to not pass $XDG_RUNTIME_DIR so that it does not break flatpaks
sed -i 's/ --xdg-runtime=\\"${XDG_RUNTIME_DIR}\\"//g' /usr/bin/btrfs-assistant-launcher

echo "::endgroup::"
