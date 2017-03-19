#!/usr/bin/env bash

# change cwd to current script dir
cd ${0%/*}

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
  sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' <<< $1
}

# run tests
setup

echo 'Running tests...'

result=$(trim "$(bundle exec vagrant run hostname)")

[[ 'primary.vagrant.devcommands' == $result ]] || {
  echo 'Default box not used...'
  echo "Got result: '${result}'"
  exit 1
}

result=$(trim "$(bundle exec vagrant run primary hostname)")

[[ 'primary.vagrant.devcommands' == $result ]] || {
  echo 'Passing default box as argv not working...'
  echo "Got result: '${result}'"
  exit 1
}

result=$(trim "$(bundle exec vagrant run secondary hostname)")

[[ 'secondary.vagrant.devcommands' == $result ]] || {
  echo 'Box passed using argv not taking precedence over configuration...'
  echo "Got result: '${result}'"
  exit 1
}

echo 'Success!'