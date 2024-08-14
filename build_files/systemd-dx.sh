#!/usr/bin/bash

set -ouex pipefail

systemctl enable docker.socket
systemctl enable podman.socket
systemctl enable swtpm-workaround.service
systemctl enable libvirt-workaround.service
systemctl enable sarkinite-dx-groups.service
systemctl enable --global sarkinite-dx-user-vscode.service
systemctl disable pmie.service
systemctl disable pmlogger.service
