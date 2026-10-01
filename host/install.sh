#!/bin/bash

# Variables
LIMA_VERSION="lima-2.2.0-Linux-x86_64.tar.gz"
LIMA_URL="https://github.com/lima-vm/lima/releases/download/v2.2.0/$LIMA_VERSION"
LIMA_SHA="a0ea1ccf6b7335a900adb5f8d2b8384457965fecb1ba72f09b4e3e46d12f424a"



check () {

    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Error: $1 is not installed." >&2
        install "$1"
    else
        echo "$1 is already installed. Nothing to install."
    fi

}

install () {
    TMP_DIR=$(mktemp -d)
    echo "Downloading $1 under $TMP_DIR"

    sudo apt update

    case "$1" in
        "lima")
            echo "Installing: $1"
            # download
            sudo apt install -y qemu-system-x86 qemu-utils
            wget "$LIMA_URL" -O "$TMP_DIR/$LIMA_VERSION"
            # checksum
            echo "$LIMA_SHA  $TMP_DIR/$LIMA_VERSION" | sha256sum -c -
            # extract
            tar -xzf "$TMP_DIR/$LIMA_VERSION" -C "$TMP_DIR"
            # move
            sudo mv "$TMP_DIR/bin/limactl" /usr/local/bin/limactl
            sudo mv "$TMP_DIR/bin/lima" /usr/local/bin/lima
            sudo cp -a "$TMP_DIR/share/lima/." /usr/local/share/lima/
            # chmod
            sudo chmod +x /usr/local/bin/limactl
            sudo chmod +x /usr/local/bin/lima
            # validate
            lima --version
            ;;
            *)
            echo "No packages to install"
            ;;

    esac
}

# TODO: include more packages if needed
for bin in lima; do
    check "$bin"
done