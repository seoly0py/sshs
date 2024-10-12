#!/bin/bash

# CHECK OS
OS="$(uname -s)"
case "$OS" in
    Linux*)     OS_TYPE="Linux";;
    Darwin*)    OS_TYPE="macOS";;
    CYGWIN*|MINGW*|MSYS*)
                echo "Windows is not supported."
                exit 1;;
    *)          OS_TYPE="Unknown";;
esac

if [ "$OS_TYPE" = "Unknown" ]; then
    echo "Unsupported OS. Exiting..."
    exit 1
fi

# CHECK ALREADY EXIST
if [ -d "$HOME/.sshs" ]; then
    echo "sshs already exist."
    exit 1
fi

# CHECK VENV AVAILABLE
PYTHON_VERSION=$(python3 --version 2>/dev/null)
if ! python3 -m venv --help >/dev/null 2>&1; then
    echo "venv is not available. Installing necessary packages..."
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
            echo "Detected Debian/Ubuntu. Installing python3-venv..."
            sudo apt update
            sudo apt install -y python3-venv
        elif [[ "$ID" == "centos" || "$ID" == "rhel" ]]; then
            echo "Detected CentOS/RHEL. Installing python3..."
            sudo yum install -y python3
        elif [[ "$ID" == "fedora" ]]; then
            echo "Detected Fedora. Installing python3..."
            sudo dnf install -y python3
        elif [[ "$ID" == "arch" ]]; then
            echo "Detected Arch Linux. Installing python..."
            sudo pacman -S --noconfirm python
        else
            echo "Unsupported distribution: $ID"
            exit 1
        fi
    else
        echo "Cannot determine the OS. Exiting script."
        exit 1
    fi

    if python3 -m venv --help >/dev/null 2>&1; then
        echo "venv is now available."
    else
        echo "Failed to install venv. Please check the installation."
        exit 1
    fi
fi

# CREATE VENV
mkdir $HOME/.sshs
python3 -m venv $HOME/.sshs/venv
source "$HOME/.sshs/venv/bin/activate"
pip install git+https://github.com/seoly0py/sshs.git
deactivate

# CREATE LOCAL BIN
if [ ! -d "$HOME/.local" ]; then
    echo "Creating ~/.local directory..."
    mkdir -p "$HOME/.local"
fi
if [ ! -d "$HOME/.local/bin" ]; then
    echo "Creating ~/.local/bin directory..."
    mkdir -p "$HOME/.local/bin"
fi

# CREATE SYMBOLIC LINK
rm -rf $HOME/.local/bin/sshs
ln -s $HOME/.sshs/venv/bin/sshs $HOME/.local/bin/sshs

# ADD PATH
LOCAL_BIN_PATH="$HOME/.local/bin"
if [[ ! ":$PATH:" == *":$LOCAL_BIN_PATH:"* ]]; then
    SHELL_CONFIG_FILE="$HOME/.bashrc"

    if [ -f "$HOME/.zshrc" ]; then
        SHELL_CONFIG_FILE="$HOME/.zshrc"
    fi

    if ! grep -q "$LOCAL_BIN_PATH" "$SHELL_CONFIG_FILE"; then
        echo "export PATH=\"\$PATH:$LOCAL_BIN_PATH\"" >> "$SHELL_CONFIG_FILE"
    fi
fi
