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
