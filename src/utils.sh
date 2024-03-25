#!/bin/bash
set -e

echoError() {
    echo -e "\033[31m  $1"
}

echoSuccess() {
    echo -e "\033[32m  $1"
}

check_credentials() {

    # Check all Dashlane and access keys are provided
    # Make them available to the current step through env vari

    if [ -z "$DASHLANE_DEVICE_ACCESS_KEY" ]; then
        echoError "DASHLANE_DEVICE_ACCESS_KEY is missing"
        exit 1
    fi

    if [ -z "$DASHLANE_DEVICE_SECRET_KEY" ]; then
        echoError "DASHLANE_DEVICE_SECRET_KEY is missing"
        exit 1
    fi

    if [ -z "$DASHLANE_LOGIN" ]; then
        echoError "DASHLANE_LOGIN is missing"
        exit 1
    fi

    if [ -z "$DASHLANE_MASTER_PASSWORD" ]; then
        echoError "DASHLANE_MASTER_PASSWORD is missing"
        exit 1
    fi

}

install_cli() {
    echo "Installing Dashlane cli on OS $OSTYPE."

    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Get runner's architecture
        ARCH=$(uname -m)

        if [[ "$ARCH" != "x86_64" ]] && [[ "$ARCH" != "aarch64" ]]; then
            echoError "Unsupported architecture for the Dashlane CLI: $ARCH."
            exit 1
        fi

        curl -sSfLo dcli  https://github.com/Dashlane/dashlane-cli/releases/download/v6.2405.0/dcli-linux-x64

    elif [[ "$OSTYPE" == "darwin"* ]]; then
        curl -sSfLo dcli  https://github.com/Dashlane/dashlane-cli/releases/download/v6.2405.0/dcli-macos-arm64
    else
        echoError "Operating system not supported yet for this GitHub Action: $OSTYPE."
        exit 1
    fi

    echoSuccess "Successfuly installed Dashlane CLI on $OSTYPE."

    chmod +x ./dcli
}

read_secrets() { 

    env_variables=$(printenv | sed 's;=.*;;' | sort)

    echo "syncronizing .."
    ./dcli sync

    is_dashlane_vault_path_found=0

    for path in $env_variables; do
        # Check if the value of the variable starts with "dl://"
        if [[ "${!path}" =~ dl://* ]]; then
            is_dashlane_vault_path_found=1
            echo "reading $path"
            echo "$path=$(./dcli read ${!path})" >> "$GITHUB_OUTPUT"
        fi
    done

    if [ $is_dashlane_vault_path_found == 0 ]; then
        echoError "No dashlane vault path has been found" 
        exit 0
    fi
}

