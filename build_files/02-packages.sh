#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

dnf5 --repofrompath=terra-extras,https://repos.fyralabs.com/terra"${FEDORA_MAJOR_VERSION}"-extras \
	--repo=terra-extras --no-gpgchecks -y swap \
	kf6-kio kf6-kio-"$(rpm -q --qf '%{VERSION}' kf6-kcoreaddons)"

dnf5 --repofrompath=terra-extras,https://repos.fyralabs.com/terra"${FEDORA_MAJOR_VERSION}"-extras \
	--repo=terra-extras --no-gpgchecks -y swap \
	switcheroo-control switcheroo-control

dnf5 --repo=fedora,updates,fedora-cisco-openh264 -y install \
	android-tools \
	bash-color-prompt \
	bcache-tools \
	borgbackup \
	bootc \
	btrfs-assistant \
	cage \
	dbus-x11 \
	ddcutil \
	edk2-ovmf \
	evtest \
	epson-inkjet-printer-escpr \
	epson-inkjet-printer-escpr2 \
	etckeeper \
	fastfetch \
	fcitx5 \
	firewall-config \
	flatpak-builder \
	foo2zjs \
	fuse-encfs \
	gcc \
	genisoimage \
	git-credential-libsecret \
	glow \
	google-noto-fonts-all \
	gstreamer1-plugin-openh264 \
	gum \
	heaptrack \
	hplip \
	iotop-c \
	kcm-fcitx5 \
	kde-runtime-docs \
	kdenetwork-filesharing \
	kdeplasma-addons \
	kdialog \
	ksystemlog \
	krb5-workstation \
	kvantum \
	ifuse \
	igt-gpu-tools \
	input-remapper \
	libimobiledevice \
	libxcrypt-compat \
	libvdpau-va-gl \
	libvirt \
	libvirt-nss \
	liquidctl \
	lm_sensors \
	lxc \
	make \
	mesa-libGLU \
	mozilla-openh264 \
	mpv \
	p7zip \
	p7zip-plugins \
	plasma-wallpapers-dynamic \
	podman-compose \
	podman-machine \
	podman-tui \
	podmansh \
	powertop \
	printer-driver-brlaser \
	pulseaudio-utils \
	python3-pip \
	python3-pygit2 \
	python3-vapoursynth \
	qdirstat \
	qemu \
	qemu-char-spice \
	qemu-device-display-virtio-gpu \
	qemu-device-display-virtio-vga \
	qemu-device-usb-redirect \
	qemu-img \
	qemu-system-x86-core \
	qemu-user-binfmt \
	qemu-user-static \
	rclone \
	restic \
	rocm-clinfo \
	rocm-hip \
	rocm-opencl \
	rocm-smi \
	rsms-inter-fonts \
	samba-dcerpc \
	samba-ldb-ldap-modules \
	samba-winbind-clients \
	samba-winbind-modules \
	samba \
	setools-console \
	skanpage \
	snapd \
	tmux \
	usbmuxd \
	waydroid \
	wireguard-tools \
	wl-clipboard \
	wlr-randr \
	xprop \
	ydotool \
	zsh

dnf5 --repofrompath=terra,https://repos.fyralabs.com/terra"${FEDORA_MAJOR_VERSION}" \
	--repo=fedora,updates,terra --no-gpgchecks -y install \
	coolercontrol \
	devpod \
	espanso-wayland \
	firacode-nerd-fonts \
	fluent-kde-theme \
	fluent-theme \
	ghostty \
	keyd \
	nerdfontssymbolsonly-nerd-fonts \
	tela-icon-theme \
	topgrade

dnf5 --repofrompath=kylegospo-rom-properties,https://download.copr.fedorainfracloud.org/results/kylegospo/rom-properties/fedora-"${FEDORA_MAJOR_VERSION}"-x86_64/ \
	--repo=fedora,kylegospo-rom-properties --no-gpgchecks -y install \
	rom-properties-kf6

dnf5 --repofrompath=kylegospo-webapp-manager,https://download.copr.fedorainfracloud.org/results/kylegospo/webapp-manager/fedora-"${FEDORA_MAJOR_VERSION}"-x86_64/ \
	--repo=fedora,updates,kylegospo-webapp-manager --no-gpgchecks -y install \
	webapp-manager

dnf5 --repofrompath=lizardbyte-stable,https://download.copr.fedorainfracloud.org/results/lizardbyte/stable/fedora-"${FEDORA_MAJOR_VERSION}"-x86_64/ \
	--repo=fedora,lizardbyte-stable --no-gpgchecks -y install \
	Sunshine

dnf5 --repofrompath=ublue-os-packages,https://download.copr.fedorainfracloud.org/results/ublue-os/packages/fedora-"${FEDORA_MAJOR_VERSION}"-x86_64/ \
	--repo=fedora,updates,ublue-os-packages --no-gpgchecks -y install \
	ublue-brew

dnf5 --repofrompath=ublue-os-staging,https://download.copr.fedorainfracloud.org/results/ublue-os/staging/fedora-"${FEDORA_MAJOR_VERSION}"-x86_64/ \
	--repo=fedora,updates,ublue-os-staging --no-gpgchecks -y install \
	yafti

dnf5 --repofrompath=docker-ce,https://download.docker.com/linux/fedora/"${FEDORA_MAJOR_VERSION}"/x86_64/stable \
	--repo=fedora,docker-ce --no-gpgchecks -y install \
	containerd.io \
	docker-ce \
	docker-ce-cli \
	docker-buildx-plugin \
	docker-compose-plugin

dnf5 --repofrompath=vscode,https://packages.microsoft.com/yumrepos/vscode \
	--repo=vscode --no-gpgchecks -y install \
	code

dnf5 --repofrompath=tailscale,https://pkgs.tailscale.com/stable/fedora/x86_64 \
	--repo=tailscale --no-gpgchecks -y install \
	tailscale

echo "::endgroup::"
