#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

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
	etckeeper \
	fastfetch \
	fcitx5 \
	ffmpegthumbnailer \
	firewall-config \
	flatpak-builder \
	foo2zjs \
	fuse-encfs \
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
	imv \
	input-remapper \
	intel-undervolt \
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
	snapd \
	system-reinstall-bootc \
	timg \
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
	--setopt=terra.gpgkey=https://repos.fyralabs.com/terra"${FEDORA_MAJOR_VERSION}"/key.asc \
	--repo=fedora,updates,terra -y install \
	coolercontrol \
	espanso-wayland \
	firacode-nerd-fonts \
	fluent-kde-theme \
	fluent-theme \
	ghostty \
	jetbrainsmono-nerd-fonts \
	keyd \
	nerdfontssymbolsonly-nerd-fonts \
	tela-icon-theme \
	topgrade \
	zed

dnf5 --repofrompath=kylegospo-rom-properties,https://download.copr.fedorainfracloud.org/results/kylegospo/rom-properties/fedora-"${FEDORA_MAJOR_VERSION}"-x86_64/ \
	--setopt=kylegospo-rom-properties.gpgkey=https://download.copr.fedorainfracloud.org/results/kylegospo/rom-properties/pubkey.gpg \
	--repo=fedora,kylegospo-rom-properties -y install \
	rom-properties-kf6

dnf5 --repofrompath=kylegospo-webapp-manager,https://download.copr.fedorainfracloud.org/results/kylegospo/webapp-manager/fedora-"${FEDORA_MAJOR_VERSION}"-x86_64/ \
	--setopt=kylegospo-webapp-manager.gpgkey=https://download.copr.fedorainfracloud.org/results/kylegospo/webapp-manager/pubkey.gpg \
	--repo=fedora,updates,kylegospo-webapp-manager -y install \
	webapp-manager

dnf5 --repofrompath=firefoxpwa,https://packagecloud.io/filips/FirefoxPWA/rpm_any/rpm_any/x86_64 \
	--setopt=firefoxpwa.gpgkey=https://packagecloud.io/filips/FirefoxPWA/gpgkey \
	--setopt=firefoxpwa.gpgcheck=0 \
	--repo=firefoxpwa -y install \
	firefoxpwa

dnf5 --repofrompath=lizardbyte-stable,https://download.copr.fedorainfracloud.org/results/lizardbyte/stable/fedora-"${FEDORA_MAJOR_VERSION}"-x86_64/ \
	--setopt=lizardbyte-stable.gpgkey=https://download.copr.fedorainfracloud.org/results/lizardbyte/stable/pubkey.gpg \
	--repo=fedora,lizardbyte-stable -y install \
	Sunshine

dnf5 --repofrompath=ublue-os-packages,https://download.copr.fedorainfracloud.org/results/ublue-os/packages/fedora-"${FEDORA_MAJOR_VERSION}"-x86_64/ \
	--setopt=ublue-os-packages.gpgkey=https://download.copr.fedorainfracloud.org/results/ublue-os/packages/pubkey.gpg \
	--repo=fedora,updates,ublue-os-packages -y install \
	ublue-brew \
	uupd

dnf5 --repofrompath=ublue-os-staging,https://download.copr.fedorainfracloud.org/results/ublue-os/staging/fedora-"${FEDORA_MAJOR_VERSION}"-x86_64/ \
	--setopt=ublue-os-staging.gpgkey=https://download.copr.fedorainfracloud.org/results/ublue-os/staging/pubkey.gpg \
	--repo=fedora,updates,ublue-os-staging -y install \
	yafti

dnf5 --repofrompath=docker-ce,https://download.docker.com/linux/fedora/"${FEDORA_MAJOR_VERSION}"/x86_64/stable \
	--setopt=docker-ce.gpgkey=https://download.docker.com/linux/fedora/gpg \
	--repo=fedora,docker-ce -y install \
	containerd.io \
	docker-ce \
	docker-ce-cli \
	docker-buildx-plugin \
	docker-compose-plugin

dnf5 --repofrompath=vscode,https://packages.microsoft.com/yumrepos/vscode \
	--setopt=vscode.gpgkey=https://packages.microsoft.com/keys/microsoft.asc \
	--repo=vscode -y install \
	code

dnf5 --repofrompath=tailscale,https://pkgs.tailscale.com/stable/fedora/x86_64 \
	--setopt=tailscale.gpgkey=https://pkgs.tailscale.com/stable/fedora/repo.gpg \
	--repo=tailscale -y install \
	tailscale

dnf5 --repofrompath=fedora-uld,https://negativo17.org/repos/uld/fedora-"${FEDORA_MAJOR_VERSION}"/x86_64/ \
	--setopt=fedora-uld.gpgkey=https://negativo17.org/repos/RPM-GPG-KEY-slaanesh \
	--repo=fedora,fedora-uld -y install \
	uld

# This is required so homebrew works indefinitely.
# Symlinking it makes it so whenever another GCC version gets released it will break if the user has updated it without-
# the homebrew package getting updated through our builds.
# We could get some kind of static binary for GCC but this is the cleanest and most tested alternative. This Sucks.
dnf5 --repo=fedora,updates --setopt=install_weak_deps=False -y install gcc

dnf5 --repofrompath=terra-extras,https://repos.fyralabs.com/terra"${FEDORA_MAJOR_VERSION}"-extras \
	--setopt=terra-extras.gpgkey=https://repos.fyralabs.com/terra"${FEDORA_MAJOR_VERSION}"-extras/key.asc \
	--repo=terra-extras -y swap \
	kf6-kio kf6-kio-"$(rpm -q --qf '%{VERSION}' kf6-kcoreaddons)"

dnf5 --repofrompath=terra-extras,https://repos.fyralabs.com/terra"${FEDORA_MAJOR_VERSION}"-extras \
	--setopt=terra-extras.gpgkey=https://repos.fyralabs.com/terra"${FEDORA_MAJOR_VERSION}"-extras/key.asc \
	--repo=terra-extras -y swap \
	switcheroo-control switcheroo-control

echo "::endgroup::"
