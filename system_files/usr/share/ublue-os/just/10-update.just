# vim: set ft=make :

alias upgrade := update
alias auto-update := toggle-updates
alias changelog := changelogs-fedora
alias changelogs := changelogs-fedora

# Update system, flatpaks, and containers all at once
update:
    #!/usr/bin/env bash
    TOPGRADE_CONFIG="/usr/share/ublue-os/topgrade"
    /usr/bin/grep "^LockLayering=true" /etc/rpm-ostreed.conf &>/dev/null && TOPGRADE_CONFIG="${TOPGRADE_CONFIG}-bootc"
    /usr/bin/topgrade --config "${TOPGRADE_CONFIG}.toml" --keep

# Turn automatic updates on or off
toggle-updates ACTION="prompt":
    #!/usr/bin/env bash
    source /usr/lib/ujust/ujust.sh
    CURRENT_STATE="Disabled"
    if systemctl is-enabled rpm-ostreed-automatic.timer | grep -q enabled; then
        CURRENT_STATE="Enabled"
    fi
    OPTION={{ ACTION }}
    if [ "$OPTION" == "prompt" ]; then
        echo "Automatic updates are currently: ${bold}${CURRENT_STATE}${normal}"
        echo "Enable or Disable automatic updates?"
        OPTION=$(ugum choose Enable Disable)
    elif [ "$OPTION" == "help" ]; then
        echo "Usage: ujust toggle-updates <option>"
        echo "  <option>: Specify the quick option - 'enable' or 'disable'"
        echo "  Use 'enable' to Enable automatic updates."
        echo "  Use 'disable' to Disable automatic updates."
        exit 0
    fi
    if [ "${OPTION,,}" == "enable" ]; then
        sudo systemctl enable rpm-ostreed-automatic.timer
    elif [ "${OPTION,,}" == "disable" ]; then
        sudo systemctl disable rpm-ostreed-automatic.timer
    fi

# Show the changelog
changelogs-sarkinite:
    #!/usr/bin/env bash
    . /etc/os-release
    # Strip Fedora's VERSION_ID from the IMAGE_VERSION
    VERSION_ID_PREFIX="${VERSION_ID}."
    IMAGE_VERSION_TAG=${IMAGE_VERSION/#"$VERSION_ID_PREFIX"}
    CONTENT=$(curl -s "https://api.github.com/repos/GarciaLnk/sarkinite/releases/tags/${RELEASE_TYPE}-${IMAGE_VERSION_TAG}"  | jq -r '.body')
    CONTENT=$(curl -s https://api.github.com/repos/GarciaLnk/sarkinite/releases/latest | jq -r '.body')
    echo "${CONTENT}" | glow -

changelogs-fedora:
    rpm-ostree db diff --changelogs
