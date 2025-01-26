# vim: set ft=make :
########################
### sarkinite-system.just
########################
## Standardized verbs
# configure- = configure something that is pre-installed on the image
# install-   = install something, no uninstall or configuration provided
# setup-     = install something and also provide configuration and/or uninstallation options
# toggle-    = turn something on/off, logic can be automatic or manual selection
# fix-       = apply fix/patch/workaround for something
# foo        = no verb is used for shortcuts or something deemed important enough to use a super memorable name

# Configure Sarkinite-CLI Terminal Experience with Brew
[group('System')]
sarkinite-cli:
    @/usr/libexec/ublue-bling.sh

# alias for toggle-devmode
devmode:
    @ujust toggle-devmode

# Toggle Developer Experience
[group('System')]
toggle-devmode:
    #!/usr/bin/env bash
    source /usr/lib/ujust/ujust.sh
    CURRENT_IMAGE=$(cat /etc/ublue/image_name)
    if grep -q "/var/ublue-os/image" <<< $CURRENT_IMAGE ; then
        cat <<EOF
    Before we can switch to the Sarkinite Developer Experience
    the current system needs an update. Please run 'ujust update'
    and reboot your system when the update is finished
    EOF
        exit
    fi
    if /bin/grep -q "\-dx" <<< $CURRENT_IMAGE ; then
        CURRENT_STATE="enabled"
    else
        CURRENT_STATE="disabled"
    fi
    echo "Developer mode is currently ${CURRENT_STATE}"
    echo "Enable or Disable developer mode"
    OPTION=$(Choose Enable Disable)
    if [[ "${OPTION,,}" =~ ^enable ]]; then
        if [ "$CURRENT_STATE" = "enabled" ] ; then
            echo "You are already on a developer image"
            exit 0
        fi
        echo "Rebasing to a developer image"
        if [[ "${CURRENT_IMAGE}" =~ "sarkinite-kde" ]]; then
            NEW_IMAGE=$(sed "s/sarkinite-kde/sarkinite-kde-dx/" <<< $CURRENT_IMAGE)
        elif [[ "${CURRENT_IMAGE}" =~ "sarkinite-gnome" ]]; then
            NEW_IMAGE=$(sed "s/sarkinite-gnome/sarkinite-gnome-dx/" <<< $CURRENT_IMAGE)
        fi
        rpm-ostree rebase $NEW_IMAGE
        echo -e "\nUse `ujust dx-group` to add your user to the correct groups and complete the installation"
    fi
    if [[ "${OPTION,,}" =~ ^disable ]]; then
        if [ "$CURRENT_STATE" != "enabled" ]; then
            echo "You are currently not on a developer image"
            exit 0
        fi
        echo "Rebasing to a non developer image"
        # Remove -dx suffix from image, specifies ":" to mark the end of the image name
        NEW_IMAGE=$(sed "s/\-dx//" <<< $CURRENT_IMAGE)
        rpm-ostree rebase $NEW_IMAGE
    fi

# alias for gnome-vrr
[group('System')]
gnome-vrr:
    @ujust toggle-gnome-vrr

# Enable or Disable Gnome-VRR
[group('System')]
toggle-gnome-vrr:
    #!/usr/bin/env bash
    source /usr/lib/ujust/ujust.sh
    if gsettings get org.gnome.mutter experimental-features | grep -q "variable-refresh-rate" ; then
        CURRENT_STATE="Enabled"
    else
        CURRENT_STATE="Disabled"
    fi
    echo "Gnome-VRR is currently ${CURRENT_STATE}"
    echo "Enable or Disable Gnome-VRR"
    OPTION=$(Choose Enable Disable)
    CURRENT_SETTINGS=($(gsettings get org.gnome.mutter experimental-features | tr -d "[]'," | xargs -n1))
    if [[ "${OPTION,,}" =~ ^enable ]]; then
        echo "Enabling Gnome-VRR"
        CURRENT_SETTINGS+=("variable-refresh-rate")
        FINAL_ARRAY=()
        for item in "${CURRENT_SETTINGS[@]}"; do
            FINAL_ARRAY+=("\"$item\"")
        done
        FINAL=$(printf "[%s]\n" "$(IFS=,; echo "${FINAL_ARRAY[*]}")")
        gsettings set org.gnome.mutter experimental-features "${FINAL}"
    fi
    if [[ "${OPTION,,}" =~ ^disable ]]; then
        echo "Disabling Gnome-VRR"
        NO_VRR_ARRAY=($(printf "%s\n" "${CURRENT_SETTINGS[@]}" | grep -v "variable-refresh-rate"))
        FINAL_ARRAY=()
        for item in "${NO_VRR_ARRAY[@]}"; do
            FINAL_ARRAY+=("\"$item\"")
        done
        FINAL=$(printf "[%s]\n" "$(IFS=,; echo "${FINAL_ARRAY[*]}")")
        gsettings set org.gnome.mutter experimental-features "${FINAL}"
    fi
    echo "To apply the changes make sure you logout and restart your session"

# Configure docker,incus-admin,libvirt container manager permissions
[group('System')]
dx-group:
    #!/usr/bin/env bash
    append_group() {
        local group_name="$1"
        if ! grep -q "^$group_name:" /etc/group; then
            echo "Appending $group_name to /etc/group"
            grep "^$group_name:" /usr/lib/group | sudo tee -a /etc/group > /dev/null
        fi
    }
    GROUPS_ADD=("docker" "incus-admin" "libvirt")
    for GROUP_ADD in "${GROUPS_ADD[@]}" ; do
        append_group $GROUP_ADD
        pkexec usermod -aG $GROUP_ADD $USER
    done
    echo "Reboot system and log back in to use docker, incus-admin, libvirt."

# alias for configure-vfio
[group('System')]
setup-vfio:
    @ujust configure-vfio

# Configure system to use vfio and kvmfr
[group('System')]
configure-vfio ACTION="":
    #!/usr/bin/env bash
    source /usr/lib/ujust/ujust.sh
    CURRENT_IMAGE=$(cat /etc/ublue/image_name)
    if grep -q "dx" <<< $CURRENT_IMAGE ; then
        DEVMODE="enabled"
    else
        DEVMODE="disabled"
    fi
    if [ "$DEVMODE" == "disabled" ]; then
        echo "Please run "ujust devmode" first"
        exit 0
    fi
    OPTION={{ ACTION }}
    if [ "$OPTION" == "help" ]; then
        cat <<EOF
    Usage: ujust configure-vfio <option>
      <option>: Specify the quick option to skip the prompt
      Use 'vfio-on' to select Enable VFIO drivers
      Use 'vfio-off' to select Disable VFIO drivers
      Use 'kvmfr' to select Autocreate Looking-Glass shm
    EOF
        exit 0
    elif [ "$OPTION" == "" ]; then
        cat <<EOF
    ${bold}VFIO and kvmfr Configuration${normal}
    This is only used for GPU passthrough of a secondary dGPU.
    It will enable vfio and configure kvmfr for use with $(Urllink "https://looking-glass.io" "Looking Glass")
    If you do not plan to use any of this then press ESC.
    ${bold}NOTE:${normal} Since this is a niche use case, support will be ${b}very limited${n}
    EOF
        OPTION=$(Choose \
          "Enable VFIO drivers" \
          "Disable VFIO drivers" \
          "Enable kvmfr module" \
        )
    fi
    if [[ "${OPTION,,}" =~ (^enable[[:space:]]vfio|vfio-on) ]]; then
        echo "Enabling VFIO..."
        CPU_VENDOR=$(grep "vendor_id" "/proc/cpuinfo" | uniq | awk -F": " '{ print $2 }')
        VENDOR_KARG="unset"
        echo 'add_drivers+=" vfio vfio_iommu_type1 vfio-pci "' | sudo tee /etc/dracut.conf.d/vfio.conf
        rpm-ostree initramfs --enable
        if [[ ${CPU_VENDOR} == "AuthenticAMD" ]]; then
            VENDOR_KARG="amd_iommu=on"
        elif [[ ${CPU_VENDOR} == "GenuineIntel" ]]; then
            VENDOR_KARG="intel_iommu=on"
        fi
        if [[ ${VENDOR_KARG} == "unset" ]]; then
            echo "Failed to get CPU vendor, exiting..."
            exit 1
        else
            rpm-ostree kargs \
                --append-if-missing="${VENDOR_KARG}" \
                --append-if-missing="iommu=pt" \
                --append-if-missing="rd.driver.pre=vfio_pci" \
                --append-if-missing="vfio_pci.disable_vga=1" \
                --append-if-missing="kvm.ignore_msrs=1" \
                --append-if-missing="kvm.report_ignored_msrs=0"
            echo "VFIO will be enabled on next boot, make sure you enable IOMMU, VT-d or AMD-v in your BIOS!"
            echo "Please understand that since this is such a niche use case, support will be very limited!"
            echo "To add your unused/second GPU device ids to the vfio driver by running"
            echo 'rpm-ostree kargs --append-if-missing="vfio-pci.ids=xxxx:yyyy,xxxx:yyzz"'
            echo "NOTE: Your second GPU will not be usable by the host after you do this!"
        fi
    elif [[ "${OPTION,,}" =~ (^disable[[:space:]]vfio|vfio-off) ]]; then
        echo ""
        echo "Make sure you have ${b}disabled autostart of all VMs using VFIO${n} before continuing!"
        CONFIRM=$(Choose Cancel Continue)
        if [ "$CONFIRM" == "Continue" ]; then
            echo "Disabling VFIO..."
            VFIO_IDS="$(rpm-ostree kargs | sed -E 's/.+(vfio_pci.ids=.+\s)/\1/' | awk '{ print $1 }' | grep vfio_pci.ids)"
            VFIO_IDS_KARG=""
            if [ -n "$VFIO_IDS" ]; then
              echo "Found VFIO ids in kargs, adding the below line to removal list"
              echo "$VFIO_IDS"
              VFIO_IDS_KARG="--delete-if-present=\"$VFIO_IDS\""
            fi
            echo "Removing dracut modules"
            sudo rm /etc/dracut.conf.d/vfio.conf
            rpm-ostree initramfs --enable
            rpm-ostree kargs \
                --delete-if-present="iommu=pt" \
                --delete-if-present="iommu=on" \
                --delete-if-present="amd_iommu=on" \
                --delete-if-present="intel_iommu=on" \
                --delete-if-present="rd.driver.pre=vfio_pci" \
                --delete-if-present="vfio_pci.disable_vga=1" \
                --delete-if-present="vfio_pci.disable_vga=0" \
            $VFIO_IDS_KARG
        fi
    elif [[ "${OPTION,,}" =~ kvmfr ]]; then
        sudo /usr/libexec/sarkinite-dx-kvmfr-setup
    fi

# Install system flatpaks for rebasers
[group('System')]
[private]
install-system-flatpaks:
    #!/usr/bin/env bash
    IMAGE_INFO="/usr/share/ublue-os/image-info.json"
    BASE_IMAGE_NAME=$(jq -r '."base-image-name"' < $IMAGE_INFO)
    if [[ ${BASE_IMAGE_NAME} == 'silverblue' ]]; then
        FLATPAKS="flatpaks_gnome/flatpaks"
    elif [[ ${BASE_IMAGE_NAME} == 'kinoite' ]]; then
        FLATPAKS="flatpaks_kde/flatpaks"
    fi
    FLATPAK_LIST="$(curl https://raw.githubusercontent.com/GarciaLnk/sarkinite/main/${FLATPAKS} | tr '\n' ' ')"
    flatpak --system -y install --or-update ${FLATPAK_LIST}

# Configure grub bootmenu visibility
[group('System')]
configure-grub:
    @/usr/libexec/configure-grub.sh

alias switch-stream := rebase-helper
alias switch-streams := rebase-helper
alias rollback-helper := rebase-helper

# Rebase assistant
[group('System')]
rebase-helper:
    @/usr/bin/ublue-rollback-helper

# Toggle tailscale
[group('System')]
toggle-tailscale:
    #!/usr/bin/env bash
    set -euo pipefail
    source /usr/lib/ujust/ujust.sh
    source /usr/lib/os-release

    TAILSCALED_STATUS="$(systemctl is-enabled tailscaled || true )"

    if [ "$TAILSCALED_STATUS" == "enabled" ] || [ "$TAILSCALED_STATUS" == "disabled" ]; then
        TAILSCALED="Installed"
    else
        TAILSCALED="Not Found"
        echo "${b}${red}Unable to enable or disable Tailscale.${n}"
        echo "The tailscaled service must be present and either enabled or disabled to run this script."
        echo "tailscaled service status: $TAILSCALED_STATUS"
    fi


    if [ "$TAILSCALED" == "Installed" ]; then
        echo "Enable or disable Tailscale?"
        TS_OPTION=$(Choose Enable Disable)

        # gnome-extensions is only available on Gnome
        if [ "$VARIANT" == "Silverblue" ]; then
            TAILSCALE_QS="$(gnome-extensions list | grep -q "tailscale@joaophi.github.com"; echo $?)"
            if [ "$TAILSCALE_QS" == 0 ]; then
                TAILSCALE_QS="Installed"
            else
                echo "The Tailscale QS extension for Gnome is not installed. Please install it and then run this script again."
            fi

            if [[ "${TS_OPTION,,}" =~ ^enable ]]; then
                gnome-extensions enable tailscale@joaophi.github.com
            elif [[ "${TS_OPTION,,}" =~ ^disable ]]; then
                gnome-extensions disable tailscale@joaophi.github.com
            fi
        fi

        if [ "$TS_OPTION" = "Enable" ]; then
            systemctl enable --now tailscaled
            TAILSCALED_STATUS="$(systemctl is-enabled tailscaled || true )"
            if [ "$TAILSCALED_STATUS" == "enabled" ]; then
                echo "${b}${green}Tailscale is enabled.${n}"
                echo "If this is your first time using Tailscale, setup is necessary."
                echo "Refer to Tailscale's documentation at https://tailscale.com/kb/1346/start."
            fi
        elif [ "$TS_OPTION" = "Disable" ]; then
            systemctl disable --now tailscaled
            TAILSCALED_STATUS="$(systemctl is-enabled tailscaled || true )"
            if [ "$TAILSCALED_STATUS" == "disabled" ]; then
                echo "${b}${red}Tailscale is disabled.${n}"
            fi
        fi
    fi

# Install Nix w/ Devbox and nixGL
[group('System')]
install-nix:
    #!/usr/bin/env bash
    echo 'Installing Nix'
    curl -Lo /tmp/nix-installer https://install.determinate.systems/nix/nix-installer-x86_64-linux
    chmod +x /tmp/nix-installer
    sudo /tmp/nix-installer install ostree --no-confirm
    rm -f /tmp/nix-installer
    sudo systemctl enable nix-gc.timer
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
    nix-channel --add https://github.com/nix-community/nixGL/archive/main.tar.gz nixgl
    nix-channel --update
    nix-env -iA nixgl.auto.nixGLDefault
    nix-env -iA nixgl.nixGLIntel
    nix-env -iA nixgl.nixVulkanIntel
    if [[ $(cat /etc/ublue/image_flavor) =~ "nvidia" ]] && [[ "$(grep -o "\-display" <<<"$(lshw -C display)")" -le 1 ]] && grep -q "vendor: NVIDIA Corporation" <<<"$(lshw -C display)"; then
      nix-env -iA nixgl.auto.nixGLNvidia
      nix-env -iA nixgl.auto.nixVulkanNvidia
    fi
    if [ ! -f "$HOME/.config/nixpkgs/config.nix" ]; then
      mkdir -p "$HOME/.config/nixpkgs"
      echo "{
      allowUnfree = true;
    }" > "$HOME/.config/nixpkgs/config.nix"
    fi
    echo 'Installing devbox!'
    curl -Lo /tmp/devbox-installer https://get.jetify.com/devbox
    chmod +x /tmp/devbox-installer
    /tmp/devbox-installer -f
    rm -f /tmp/devbox-installer
    if ! grep -q 'eval "$(devbox global shellenv)"' "$HOME/.bashrc"; then
      echo 'eval "$(devbox global shellenv)"' | sudo tee -a "$HOME/.bashrc" > /dev/null
    fi
    if ! grep -q "export XDG_DATA_DIRS=" "$HOME/.profile" 2>/dev/null; then
      if [ ! -f "$HOME/.profile" ]; then
        touch "$HOME/.profile"
      fi
      echo "export XDG_DATA_DIRS=\"$(devbox global path)/.devbox/nix/profile/default/share:$HOME/.nix-profile/share:\$XDG_DATA_DIRS\"" | tee -a "$HOME/.profile" > /dev/null
    fi
    echo 'Open a new shell to continue'

alias setup-nix := install-nix

# Update Nix and Devbox
[group('System')]
update-nix:
    #!/usr/bin/env bash
    echo 'Updating Nix'
    # sudo -i nix upgrade-nix
    devbox global update

# Remove Nix and Devbox
[group('System')]
remove-nix:
    #!/usr/bin/env bash
    echo 'Removing Nix'
    /nix/nix-installer uninstall
    sudo systemctl disable nix-gc.timer
    sed -i '/eval "$(devbox global shellenv)"/d' "$HOME/.bashrc"
    sed -i '/export XDG_DATA_DIRS=/d' "$HOME/.profile"
    sudo rm /usr/local/bin/devbox
    rm -rf ~/.cache/devbox
    rm -rf .local/share/devbox

[group('System')]
configure-hostname:
    #!/usr/bin/env bash
    source /usr/lib/ujust/ujust.sh
    echo "Current hostname: $(hostname)"
    echo "Enter the new hostname:"
    read NEW_HOSTNAME
    sudo hostnamectl set-hostname $NEW_HOSTNAME
    echo "Hostname changed to $NEW_HOSTNAME"

alias hostname := configure-hostname

# Setup SSH keys
[group('System')]
setup-ssh:
    #!/usr/bin/env bash
    if ! [[ -f "$HOME/.ssh/authorized_keys" ]]; then
      mkdir -p "$HOME/.ssh"
      chmod 700 "$HOME/.ssh"
      ssh-keygen -t ed25519 -f "$HOME/.ssh/id_ed25519" -N "" -C "$USER@$HOSTNAME"
      cat "$HOME/.ssh/id_ed25519.pub" >> "$HOME/.ssh/authorized_keys"
      eval "$(ssh-agent -s)"
      ssh-add "$HOME/.ssh/id_ed25519"
    fi

    if ! grep -q "SSH_AUTH_SOCK" "$HOME/.profile" 2>/dev/null; then
      cat >> "$HOME/.profile" << EOF
    if [[ -z \${SSH_AUTH_SOCK} ]]; then
        # Check for a currently running instance of the agent
        RUNNING_AGENT="\$(pgrep -fc 'ssh-agent -s')"
        if [[ \${RUNNING_AGENT} == "0" ]]; then
            # Launch a new instance of the agent
            ssh-agent -s &>"\${HOME}/.ssh/ssh-agent"
        fi
        eval "\$(cat "\${HOME}/.ssh/ssh-agent")" >/dev/null
        ssh-add "\${HOME}/.ssh/id_ed25519" 2>/dev/null
    fi
    EOF
    fi

# Add .desktop file to reboot into Windows if dual-booting
[group('System')]
setup-boot-windows:
    #!/usr/bin/env bash
    boot_number=$(efibootmgr | grep -oP "Boot\K\d{4}(?=[\* ]*Windows)" | head -n 1)
    if [[ -n ${boot_number} ]]; then
        mkdir -p "${HOME}/.local/share/applications"
        echo "Making efibootmgr -n usable without sudo password"
        echo "%wheel ALL=(root) NOPASSWD: /usr/sbin/efibootmgr" | sudo tee /etc/sudoers.d/efibootmgr-config
        echo "Adding shortcut to reboot into Windows"
        cat <<EOF >"${HOME}/.local/share/applications/reboot-windows.desktop"
    [Desktop Entry]
    Type=Application
    Name=Boot Windows
    Comment=Reboot into Windows
    Exec=/usr/bin/boot-windows
    Icon=windows
    Terminal=false
    Categories=System;
    EOF
    else
        echo "Cannot find Windows boot in EFI"
    fi
