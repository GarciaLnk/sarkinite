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

# Install GitHub Copilot CLI
[group('Apps')]
install-copilot-cli:
    #!/usr/bin/env bash
    echo "Installing GitHub Copilot CLI..."
    if [[ -n $(command -v gh) ]]; then
        if [[ -z $(gh auth status) ]]; then
            gh auth login
        fi
        gh extension install github/gh-copilot --force
        if ! grep -q 'gh copilot alias' ~/.bashrc; then
            echo 'eval "$(gh copilot alias -- bash)"' >> ~/.bashrc
        fi
        echo "Start using GitHub Copilot by typing 'ghcs' in a new terminal."
    else
        echo "GitHub CLI is not installed. Please install it first."
    fi

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
    SCRIPTS_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/mpv/scripts"
    curl "https://raw.githubusercontent.com/wis/mpvSockets/master/mpvSockets.lua" --create-dirs -o "${SCRIPTS_DIR}/mpvSockets.lua"
    echo "SVP has been installed."

# Install gaming apps
[group('Apps')]
install-gaming-apps:
    #!/usr/bin/env bash
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak --system -y install --or-update app/com.valvesoftware.Steam/x86_64/stable \
                                            app/com.heroicgameslauncher.hgl/x86_64/stable \
                                            app/net.lutris.Lutris/x86_64/stable \
                                            app/com.vysp3r.ProtonPlus/x86_64/stable \
                                            app/com.github.Matoking.protontricks/x86_64/stable \
                                            runtime/com.obsproject.Studio.Plugin.OBSVkCapture/x86_64/stable \
                                            runtime/org.freedesktop.Platform.VulkanLayer.gamescope/x86_64/23.08 \
                                            runtime/org.freedesktop.Platform.VulkanLayer.gamescope/x86_64/24.08 \
                                            runtime/org.freedesktop.Platform.VulkanLayer.OBSVkCapture/x86_64/23.08 \
                                            runtime/org.freedesktop.Platform.VulkanLayer.OBSVkCapture/x86_64/24.08 \
                                            runtime/org.freedesktop.Platform.VulkanLayer.MangoHud/x86_64/23.08 \
                                            runtime/org.freedesktop.Platform.VulkanLayer.MangoHud/x86_64/24.08

# Install Java through Homebrew
[group('Apps')]
install-java:
    #!/usr/bin/env bash
    brew install openjdk
    bash -c "cat > "${HOME}/.local/share/applications/openjdk.desktop" <<EOF
    [Desktop Entry]
    Name=OpenJDK Java Runtime
    Comment=OpenJDK Java Runtime
    Keywords=java;runtime
    Exec=/var/home/linuxbrew/.linuxbrew/bin/java -jar %f
    Terminal=false
    Type=Application
    Icon=java-jdk
    MimeType=application/x-java-archive;application/java-archive;application/x-jar;
    NoDisplay=true
    EOF"


# Install OpenTabletDriver, an open source, cross-platform, user-mode tablet driver
[group('Apps')]
install-opentabletdriver:
    #!/usr/bin/env bash
    source /usr/lib/ujust/ujust.sh
    echo "Installer for OpenTabletDriver..."
    echo "${bold}Install or Remove OpenTabletDriver${normal}"
    OPTION=$(Choose "Install" "Uninstall" "Exit")
    if [[ "${OPTION,,}" =~ ^install ]]; then
        echo "Installing OpenTabletDriver..."
        curl -s https://api.github.com/repos/OpenTabletDriver/OpenTabletDriver/releases/latest \
        | jq -r '.assets | sort_by(.created_at) | .[] | select (.name|test("opentabletdriver.*tar.gz$")) | .browser_download_url' \
        | wget -qi - -O /tmp/OpenTabletDriver/opentabletdriver.tar.gz && \
        tar --strip-components=1 -xvzf /tmp/OpenTabletDriver/opentabletdriver.tar.gz -C /tmp/OpenTabletDriver && \
        pkexec cp /tmp/OpenTabletDriver/etc/udev/rules.d/70-opentabletdriver.rules /etc/udev/rules.d/71-opentabletdriver.rules && \
        rm -rf /tmp/OpenTabletDriver && \
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo && \
        flatpak --system install -y flathub net.opentabletdriver.OpenTabletDriver && \
        mkdir -p $HOME/.config/OpenTabletDriver && \
        flatpak override --user --filesystem=xdg-config/OpenTabletDriver net.opentabletdriver.OpenTabletDriver && \
        mkdir -p $HOME/.config/systemd/user && \
        curl -s https://raw.githubusercontent.com/flathub/net.opentabletdriver.OpenTabletDriver/refs/heads/master/scripts/opentabletdriver.service > $HOME/.config/systemd/user/opentabletdriver.service  && \
        systemctl --user daemon-reload && \
        systemctl enable --user --now opentabletdriver.service
    elif [[ "${OPTION,,}" =~ ^uninstall ]]; then
        echo "Uninstalling OpenTabletDriver..."
        pkexec rm /etc/udev/rules.d/71-opentabletdriver.rules && \
        flatpak --system remove -y flathub net.opentabletdriver.OpenTabletDriver
    else
        echo "Have a good day :)!"
    fi
