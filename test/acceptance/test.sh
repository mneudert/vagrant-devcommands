#!/usr/bin/env bash

# change cwd to current script dir
cd "${0%/*}" || exit 127

# setup global configuration
export BUNDLE_GEMFILE='../../Gemfile'
export VAGRANT_I_KNOW_WHAT_IM_DOING_PLEASE_BE_QUIET='true'

# utility functions
setup() {
  echo 'Installing dependencies...'
  bundle install > /dev/null

  echo 'Starting containers...'
  bundle exec vagrant up > /dev/null

  trap teardown EXIT
}

teardown() {
  echo 'Destroying containers...'
  bundle exec vagrant destroy -f > /dev/null
}

trim() {
  sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' <<< "${1}"
}

# run tests
setup

echo 'Running tests...'

. ./test_commands.sh

. ./test_aliases.sh
. ./test_box-name-clash.sh
. ./test_chains.sh
. ./test_completion-data.sh
. ./test_did-you-mean.sh

echo 'Success!'
