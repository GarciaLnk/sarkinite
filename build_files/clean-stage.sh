#!/usr/bin/env bash
#shellcheck disable=SC2115

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

rm -rf /tmp/* || true
rm -rf /tmp/* || true
find /var/* -maxdepth 0 -type d \! -name cache -exec rm -fr {} \;
find /var/cache/* -maxdepth 0 -type d \! -name libdnf5 \! -name rpm-ostree -exec rm -fr {} \;

echo "::endgroup::"
