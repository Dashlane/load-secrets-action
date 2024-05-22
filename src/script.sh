#!/bin/bash

set -e

source ./src/utils.sh

check_credentials
install_cli
read_secrets
