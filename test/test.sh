#!/bin/bash
set -e

assert_secret() {
  if [ "$(printenv $1)" != "$2" ]; then
    echo -e "Expected $1 to be set to:\n$2\nBut got:\n$(printenv $1)"
    exit 1
  fi
}

assert_secret "ACTION_SECRET_PASSWORD" "action_test"
assert_secret "ACTION_SECRET_NOTE" "action_test"
 
