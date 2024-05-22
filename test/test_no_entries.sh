#!/bin/bash

set -e

assert_no_secret() {
    if [ -z "$(printenv "$1")" ]; then
        exit 0
    fi
}

assert_no_secret "ACTION_SECRET_PASSWORD"
