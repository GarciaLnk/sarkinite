#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

# Prevent partial upgrading
dnf5 versionlock add plasma-desktop

dnf5 --repo=fedora,updates,updates-archive,fedora-cisco-openh264 -y install \
	android-tools \
	borgbackup \
	btrfs-assistant \
	cage \
	davfs2 \
	edk2-ovmf \
	evtest \
	etckeeper \
	fastfetch \
	ffmpegthumbnailer \
	flatpak-builder \
	foo2zjs \
	gamescope \
	genisoimage \
	git-credential-libsecret \
	glow \
	gstreamer1-plugin-openh264 \
	gum \
	gvfs \
	gvfs-fuse \
	heaptrack \
	iotop-c \
	ksystemlog \
	krb5-workstation \
	kvantum \
	ifuse \
	igt-gpu-tools \
	imv \
	input-remapper \
	intel-undervolt \
	iwd \
	libxcrypt-compat \
	libvdpau-va-gl \
	libvirt \
	libvirt-nss \
	liquidctl \
	lm_sensors \
	lxc \
	mangohud \
	mozilla-openh264 \
	mpv \
	p7zip \
	plasma-firewall-"$(rpm -q --qf '%{VERSION}' plasma-desktop)" \
	plasma-wallpapers-dynamic \
	podman-compose \
	podman-machine \
	podman-tui \
	podmansh \
	powertop \
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
	rsms-inter-fonts \
	samba-winbind \
	samba-winbind-clients \
	samba-winbind-modules \
	setools-console \
	snapd \
	system-reinstall-bootc \
	timg \
	usbip \
	virtualbox-guest-additions \
	vkBasalt \
	waydroid \
	wlr-randr \
	ydotool

dnf5 clean all

dnf5 --repofrompath=terra,https://repos.fyralabs.com/terra"${FEDORA_MAJOR_VERSION}" \
	--setopt=terra.gpgkey=https://repos.fyralabs.com/terra"${FEDORA_MAJOR_VERSION}"/key.asc \
	--repo=fedora,updates,terra -y install \
	cleartype-fonts \
	coolercontrol \
	dwarfs \
	espanso-wayland \
	firacode-nerd-fonts \
	fluent-kde-theme \
	fluent-theme \
	ghostty \
	heroic-games-launcher \
	jetbrainsmono-nerd-fonts \
	keyd \
	ms-core-fonts \
	ms-core-tahoma-fonts \
	nerdfontssymbolsonly-nerd-fonts \
	tela-icon-theme \
	topgrade

dnf5 --repofrompath=terra-extras,https://repos.fyralabs.com/terra"${FEDORA_MAJOR_VERSION}"-extras \
	--setopt=terra-extras.gpgkey=https://repos.fyralabs.com/terra"${FEDORA_MAJOR_VERSION}"-extras/key.asc \
	--repo=fedora,updates,terra-extras -y install \
	terra-wine-staging \
	terra-winetricks

dnf5 --repofrompath=bazzite-org-rom-properties,https://download.copr.fedorainfracloud.org/results/bazzite-org/rom-properties/fedora-"${FEDORA_MAJOR_VERSION}"-x86_64/ \
	--setopt=bazzite-org-rom-properties.gpgkey=https://download.copr.fedorainfracloud.org/results/bazzite-org/rom-properties/pubkey.gpg \
	--repo=fedora,bazzite-org-rom-properties -y install \
	rom-properties-kf6

dnf5 --repofrompath=bazzite-org-webapp-manager,https://download.copr.fedorainfracloud.org/results/bazzite-org/webapp-manager/fedora-"${FEDORA_MAJOR_VERSION}"-x86_64/ \
	--setopt=bazzite-org-webapp-manager.gpgkey=https://download.copr.fedorainfracloud.org/results/bazzite-org/webapp-manager/pubkey.gpg \
	--repo=fedora,updates,bazzite-org-webapp-manager -y install \
	webapp-manager

dnf5 --repofrompath=firefoxpwa,https://packagecloud.io/filips/FirefoxPWA/rpm_any/rpm_any/x86_64 \
	--setopt=firefoxpwa.gpgkey=https://packagecloud.io/filips/FirefoxPWA/gpgkey \
	--setopt=firefoxpwa.gpgcheck=0 \
	--repo=firefoxpwa -y install \
	firefoxpwa

dnf5 --repofrompath=lizardbyte-beta,https://download.copr.fedorainfracloud.org/results/lizardbyte/beta/fedora-"${FEDORA_MAJOR_VERSION}"-x86_64/ \
	--setopt=lizardbyte-beta.gpgkey=https://download.copr.fedorainfracloud.org/results/lizardbyte/beta/pubkey.gpg \
	--repo=fedora,lizardbyte-beta -y install \
	Sunshine

dnf5 --repofrompath=ublue-os-packages,https://download.copr.fedorainfracloud.org/results/ublue-os/packages/fedora-"${FEDORA_MAJOR_VERSION}"-x86_64/ \
	--setopt=ublue-os-packages.gpgkey=https://download.copr.fedorainfracloud.org/results/ublue-os/packages/pubkey.gpg \
	--repo=fedora,updates,ublue-os-packages -y install \
	uupd

dnf5 --repofrompath=docker-ce,https://download.docker.com/linux/fedora/"${FEDORA_MAJOR_VERSION}"/x86_64/stable \
	--setopt=docker-ce.gpgkey=https://download.docker.com/linux/fedora/gpg \
	--repo=fedora,docker-ce -y install \
	containerd.io \
	docker-ce \
	docker-ce-cli \
	docker-buildx-plugin \
	docker-compose-plugin \
	docker-model-plugin

dnf5 --repofrompath=antigravity,https://us-central1-yum.pkg.dev/projects/antigravity-auto-updater-dev/antigravity-rpm \
	--setopt=antigravity.gpgcheck=0 \
	--repo=antigravity -y install \
	antigravity

dnf5 --repofrompath=vscode,https://packages.microsoft.com/yumrepos/vscode \
	--setopt=vscode.gpgkey=https://packages.microsoft.com/keys/microsoft.asc \
	--repo=vscode -y install \
	code

dnf5 config-manager addrepo --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo
dnf5 -y install tailscale
rm -f /etc/yum.repos.d/tailscale.repo

dnf5 --repofrompath=fedora-uld,https://negativo17.org/repos/uld/fedora-"${FEDORA_MAJOR_VERSION}"/x86_64/ \
	--setopt=fedora-uld.gpgkey=https://negativo17.org/repos/RPM-GPG-KEY-slaanesh \
	--repo=fedora,fedora-uld -y install \
	uld

dnf5 clean all

echo "::endgroup::"
