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

# Run a one minute system benchmark
benchmark:
    echo 'Running a 1 minute benchmark ...'
    cd /tmp && stress-ng --matrix 0 -t 1m --times

# Configure Sarkinite-CLI Terminal Experience with Brew
sarkinite-cli:
    @/usr/libexec/ublue-bling.sh

# Toggle between Sarkinite and the Developer Experience
devmode:
    #!/usr/bin/env bash
    CURRENT_IMAGE=$(rpm-ostree status -b --json | jq -r '.deployments[0]."container-image-reference"')
    if grep -q "/var/ublue-os/image" <<< $CURRENT_IMAGE
    then
        echo ""
        echo "Before we can switch to the Sarkinite Developer Experience"
        echo "the current system needs an update. Please run 'just update'"
        echo "and reboot your system when the update is finished."
        exit
    fi
    if grep -q "dx" <<< $CURRENT_IMAGE
    then
        CURRENT_STATE="enabled"
    else
        CURRENT_STATE="disabled"
    fi
    echo "Developer mode is currently ${CURRENT_STATE}"
    echo "Enable or Disable developer mode"
    OPTION=$(gum choose Enable Disable)
    if [ "$OPTION" = "Enable" ]
    then
        if [ "$CURRENT_STATE" = "enabled" ]
        then
            echo "You are already on a developer image"
        else
            echo "Rebasing to a developer image"
            NEW_IMAGE=$(echo $CURRENT_IMAGE | sed "s/sarkinite/sarkinite-dx/")
            rpm-ostree rebase $NEW_IMAGE
        fi
    elif [ "$OPTION" = "Disable" ]
    then
        if [ "$CURRENT_STATE" = "enabled" ]
        then
            echo "Rebasing to a non developer image"
            NEW_IMAGE=$(echo $CURRENT_IMAGE | sed "s/sarkinite-dx/sarkinite/")
            rpm-ostree rebase $NEW_IMAGE
        else
            echo "You are currently not on a developer image"
        fi
    fi

alias shell := configure-shell

# Switch to a different shell
configure-shell ACTION="":
    #!/bin/bash
    source /usr/lib/ujust/ujust.sh
    CURRENT_SHELL="$(cat /etc/passwd | grep ":$UID:" | cut '-d:' '-f7')"
    OPTION={{ ACTION }}
    if [ "$OPTION" == "help" ]; then
      echo "Usage: ujust shell <option>"
      echo "  <option>: Specify the quick option to skip the prompt"
      echo "  Use 'fish' to select fish"
      echo "  Use 'zsh' to select zsh"
      echo "  Use 'bash' to select bash"
      exit 0
    elif [ "$OPTION" == "" ]; then
      echo "${bold}Shell configuration${normal}"
      echo "${USER}'s shell is currently ${CURRENT_SHELL}"
      OPTION=$(Choose "fish" "zsh" "bash")
    fi
    if [ -z "$OPTION" ]; then
      exit 0
    else
      sudo usermod $USER --shell /usr/bin/$OPTION 
      printf "${USER}'s shell is now %s.\n" "$(cat /etc/passwd | grep ":$UID:" | cut '-d:' '-f7')"
    fi

alias gnome-vrr := toggle-gnome-vrr

# Enable or Disable Gnome-VRR
toggle-gnome-vrr:
    #!/usr/bin/env bash
    if gsettings get org.gnome.mutter experimental-features | grep -q "variable-refresh-rate"
    then
      CURRENT_STATE="Enabled"
    else
      CURRENT_STATE="Disabled"
    fi
    echo "Gnome-VRR is currently ${CURRENT_STATE}"
    echo "Enable or Disable Gnome-VRR"
    OPTION=$(gum choose Enable Disable)
    if [ "$OPTION" = "Enable" ]
    then
      echo "Enabling Gnome-VRR"
      gsettings set org.gnome.mutter experimental-features "['variable-refresh-rate','scale-monitor-framebuffer']"
    elif [ "$OPTION" = "Disable" ]
    then
      echo "Disabling Gnome-VRR"
      gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
    fi
    echo "To apply the changes make sure you logout and restart your session"

# Configure docker,incus-admin,lxd,libvirt container manager permissions
dx-group:
    sudo usermod -aG docker $USER
    sudo usermod -aG incus-admin $USER
    sudo usermod -aG lxd $USER
    sudo usermod -aG libvirt $USER
    @echo "Logout to use docker, incus-admin, lxd, libvirt"

# Configure system to use vfio and kvmfr
configure-vfio ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    CURRENT_IMAGE=$(rpm-ostree status -b --json | jq -r '.deployments[0]."container-image-reference"')
    if grep -q "dx" <<< $CURRENT_IMAGE
    then
      DEVMODE="enabled"
    else
      DEVMODE="disabled"
    fi
    if [ "$DEVMODE" == "disabled" ]; then
      echo 'Please run "ujust devmode" first'
      exit 0
    fi
    OPTION={{ ACTION }}
    if [ "$OPTION" == "help" ]; then
      echo "Usage: ujust configure-vfio <option>"
      echo "  <option>: Specify the quick option to skip the prompt"
      echo "  Use 'vfio-on' to select Enable VFIO drivers"
      echo "  Use 'vfio-off' to select Disable VFIO drivers"
      echo "  Use 'kvmfr' to select Autocreate Looking-Glass shm"
      exit 0
    elif [ "$OPTION" == "" ]; then
      echo "${bold}VFIO and kvmfr Configuration${normal}"
      echo "This is only used for GPU passthrough of a secondary dGPU."
      echo "It will enable vfio and configure kvmfr for use with $(Urllink "https://looking-glass.io" "Looking Glass")"
      echo "If you do not plan to use any of this then press ESC."
      echo "${bold}NOTE:${normal} Since this is a niche use case, support will be ${b}very limited${n}"
      OPTION=$(Choose \
        "Enable VFIO drivers" \
        "Disable VFIO drivers" \
        "Enable kvmfr module" \
      )
    fi
    if [[ "${OPTION,,}" =~ (^enable[[:space:]]vfio|vfio-on) ]]; then
      echo "Enabling VFIO..."
      VIRT_TEST=$(rpm-ostree kargs)
      CPU_VENDOR=$(grep "vendor_id" "/proc/cpuinfo" | uniq | awk -F": " '{ print $2 }')
      VENDOR_KARG="unset"
      if [[ ${VIRT_TEST} == *kvm.report_ignored_msrs* ]]; then
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
            --append-if-missing="vfio_pci.disable_vga=1"
          echo "VFIO will be enabled on next boot, make sure you enable IOMMU, VT-d or AMD-v in your BIOS!"
          echo "Please understand that since this is such a niche use case, support will be very limited!"
          echo "To add your unused/second GPU device ids to the vfio driver by running"
          echo 'rpm-ostree kargs --append-if-missing="vfio-pci.ids=xxxx:yyyy,xxxx:yyzz"'
          echo "NOTE: Your second GPU will not be usable by the host after you do this!"
        fi
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
[private]
install-system-flatpaks:
    #!/usr/bin/bash
    IMAGE_INFO="/usr/share/ublue-os/image-info.json"
    BASE_IMAGE_NAME=$(jq -r '."base-image-name"' < $IMAGE_INFO)
    if [[ ${BASE_IMAGE_NAME} == 'silverblue' ]]; then
        FLATPAKS="flatpaks_gnome/flatpaks"
    elif [[ ${BASE_IMAGE_NAME} == 'kinoite' ]]; then
        FLATPAKS="flatpaks_kde/flatpaks"
    elif [[ ${BASE_IMAGE_NAME} == 'sericea' ]]; then
        FLATPAKS="flatpaks_sway/flatpaks"
    fi
    FLATPAK_LIST="$(curl https://raw.githubusercontent.com/GarciaLnk/sarkinite/main/${FLATPAKS} | tr '\n' ' ')"
    flatpak --system -y install --or-update ${FLATPAK_LIST}

# Configure grub bootmenu visibility
configure-grub:
    @/usr/libexec/configure-grub.sh

# Rebase assistant
rebase-helper:
    @/usr/bin/ublue-rollback-helper

alias rollback-helper := rebase-helper
alias switch-channel := rebase-helper

update-ng:
    echo "Note: This command doesn't work if you have locally layered packages" 
    sudo bootc upgrade
    flatpak update -y
    brew upgrade

# Toggle tailscale
toggle-tailscale:
    #!/bin/bash
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
      TS_OPTION=$(ugum choose Enable Disable)

      # gnome-extensions is only available on Bluefin (Gnome)
      if [ "$VARIANT" == "silverblue" ]; then
        TAILSCALE_QS="$(gnome-extensions list | grep -q "tailscale@joaophi.github.com"; echo $?)"
        if [ "$TAILSCALE_QS" == 0 ]; then
          TAILSCALE_QS="Installed"
        else
          echo "The Tailscale QS extension for Gnome is not installed. Please install it and then run this script again."
        fi

        if [ "$TS_OPTION" = "Enable" ]; then
          gnome-extensions enable tailscale@joaophi.github.com
        elif [ "$TS_OPTION" = "Disable" ]; then
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

# Install nix and Devbox
nix-devbox:
    #!/usr/bin/bash
    echo 'Installing nix.'
    curl -Lo /tmp/nix-installer https://install.determinate.systems/nix/nix-installer-x86_64-linux
    chmod +x /tmp/nix-installer
    sudo /tmp/nix-installer install ostree --no-confirm
    rm -f /tmp/nix-installer
    sudo systemctl enable nix-gc.timer
    echo 'Installing devbox!'
    curl -Lo /tmp/devbox-installer https://get.jetify.com/devbox
    chmod +x /tmp/devbox-installer
    /tmp/devbox-installer -f
    rm -f /tmp/devbox-installer
    echo 'eval "$(devbox global shellenv)"' | sudo tee -a /etc/bashrc > /dev/null
    sudo systemctl enable devbox-update.timer
    echo 'Open a new shell to continue'

alias install-nix := nix-devbox
alias setup-nix := nix-devbox

# Update nix
update-nix:
    #!/usr/bin/bash
    echo 'Updating nix.'
    sudo -i /nix/var/nix/profiles/default/bin/nix upgrade-nix --nix-store-paths-url \
    https://releases.nixos.org/nix/nix-$(curl -s https://api.github.com/repos/DeterminateSystems/nix/tags | \
    jq -r '.[0].name' | cut -c2-)/fallback-paths.nix

# Remove nix
remove-nix:
    #!/usr/bin/bash
    echo 'Removing nix.'
    /nix/nix-installer uninstall
    sudo systemctl disable nix-gc.timer
    sudo systemctl disable devbox-update.timer

change-hostname:
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    echo "Current hostname: $(hostname)"
    echo "Enter the new hostname:"
    read NEW_HOSTNAME
    sudo hostnamectl set-hostname $NEW_HOSTNAME
    echo "Hostname changed to $NEW_HOSTNAME"

alias hostname := change-hostname
