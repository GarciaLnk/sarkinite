#!/usr/bin/env bash
#shellcheck disable=SC2115

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

shopt -s extglob

rm -rf /tmp/* || true
rm -rf /var/!(cache)
rm -rf /var/cache/!(rpm-ostree)

echo "::endgroup::"
