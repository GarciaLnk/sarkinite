# vim: set ft=make :
########################
### sarkinite-apps.just
########################
## Standardized verbs
# configure- = configure something that is pre-installed on the image
# install-   = install something, no uninstall or configuration provided
# setup-     = install something and also provide configuration and/or uninstallation options
# toggle-    = turn something on/off, logic can be automatic or manual selection
# fix-       = apply fix/patch/workaround for something
# foo        = no verb is used for shortcuts or something deemed important enough to use a super memorable name

# alias for install-jetbrains-toolbox
[group('Apps')]
jetbrains-toolbox:
    @ujust install-jetbrains-toolbox

# Install JetBrains Toolbox | https://www.jetbrains.com/toolbox-app/
[group('Apps')]
install-jetbrains-toolbox:
    #!/usr/bin/env bash
    pushd "$(mktemp -d)"
    echo "Get latest JetBrains Toolbox version"
    # Get the json with latest releases
    curl -sSfL -o releases.json "https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release"
    # Extract information
    BUILD_VERSION=$(jq -r '.TBA[0].build' ./releases.json)
    DOWNLOAD_LINK=$(jq -r '.TBA[0].downloads.linux.link' ./releases.json)
    CHECKSUM_LINK=$(jq -r '.TBA[0].downloads.linux.checksumLink' ./releases.json)
    echo "Installing JetBrains Toolbox ${BUILD_VERSION}"
    curl -sSfL -O "${DOWNLOAD_LINK}"
    curl -sSfL "${CHECKSUM_LINK}" | sha256sum -c
    tar zxf jetbrains-toolbox-"${BUILD_VERSION}".tar.gz
    echo "Launching JetBrains Toolbox"
    ./jetbrains-toolbox-"${BUILD_VERSION}"/jetbrains-toolbox

# alias for install-incus
[group('Apps')]
incus:
    @ujust install-incus

# Install and configure Incus
[group('Apps')]
install-incus:
    #!/usr/bin/env bash
    source /usr/lib/ujust/ujust.sh
    CURRENT_IMAGE=$(rpm-ostree status -b --json | jq -r '.deployments[0]."container-image-reference"')
    if ! grep -e "-dx" <<< $CURRENT_IMAGE ; then
        echo "Developer mode is currently ${b}${red}Disabled${n}."
        echo "Run \"just devmode\" to turn on Developer mode."
        exit
    fi
    echo 'Installing and configuring Incus.'
    /usr/libexec/sarkinite-incus

alias spotify := setup-spotify

# Configure Spotify with Spicetify
[group('Apps')]
setup-spotify:
    #!/usr/bin/env bash
    if ! flatpak list | grep -q "com.spotify.Client"; then
        echo "Installing Spotify Flatpak"
        flatpak install --user -y flathub com.spotify.Client
    fi
    flatpak run com.spotify.Client & disown > /dev/null 2>&1 & sleep 5
    echo "Configuring Spotify with Spicetify"
    brew install spicetify-cli
    spicetify backup apply
    sed -i "/prefs_path/c\prefs_path             = $HOME/.var/app/com.spotify.Client/config/spotify/prefs" "$HOME/.config/spicetify/config-xpui.ini"
    chmod a+wr "$HOME/.local/share/flatpak/app/com.spotify.Client/x86_64/stable/active/files/extra/share/spotify"
    chmod a+wr -R "$HOME/.local/share/flatpak/app/com.spotify.Client/x86_64/stable/active/files/extra/share/spotify/Apps"
    curl -Lo /tmp/spicetify-marketplace.sh https://raw.githubusercontent.com/spicetify/marketplace/main/resources/install.sh
    chmod +x /tmp/spicetify-marketplace.sh
    /tmp/spicetify-marketplace.sh
    spicetify config extensions popupLyrics.js
    spicetify config extensions shuffle+.js
    curl -Lo "$HOME/.config/spicetify/Extensions/adblock.js" "https://raw.githubusercontent.com/rxri/spicetify-extensions/main/adblock/adblock.js"
    spicetify config extensions adblock.js
    spicetify apply

# Install Kubernetes CLI dev tools
[group('Apps')]
install-k8s-dev-tools:
    #!/usr/bin/env bash
    echo "Adding Kubernetes command line tools..."
    brew bundle --file /usr/share/ublue-os/homebrew/kubernetes.Brewfile

# Install SVP
[group('Apps')]
install-svp:
    #!/usr/bin/env bash
    if [[ -d "${HOME}/.local/share/svp4" ]]; then
        echo "SVP is already installed."
        exit 0
    fi
    echo "Downloading SVP..."
    curl -Lo /tmp/svp4-linux-x64.tar.bz2 https://www.svp-team.com/files/svp4-linux.4.6.263.tar.bz2
    echo "Extracting SVP..."
    tar -xjf /tmp/svp4-linux-x64.tar.bz2 -C /tmp
    echo "Installing SVP, set install directory to ${HOME}/.local/share/svp4"
    /tmp/svp4-linux-64.run
    rm -f /tmp/svp4-linux-x64.tar.bz2 /tmp/svp4-linux-64.run
    SCRIPTS_DIR="${HOME}/.config/mpv/scripts"
    curl "https://raw.githubusercontent.com/wis/mpvSockets/master/mpvSockets.lua" --create-dirs -o "${SCRIPTS_DIR}/mpvSockets.lua"
    echo "SVP has been installed."
