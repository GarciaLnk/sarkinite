#!/usr/bin/bash
#shellcheck disable=SC2115

set -eoux pipefail
shopt -s extglob

rm -rf /tmp/* || true
rm -rf /var/!(cache)
rm -rf /var/cache/!(rpm-ostree)
