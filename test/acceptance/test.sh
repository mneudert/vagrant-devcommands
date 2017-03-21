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

## COMMANDS
result=$(trim "$(bundle exec vagrant run hostname)")

[[ 'primary.vagrant.devcommands' == "${result}" ]] || {
  echo 'Default box not used...'
  echo "Got result: '${result}'"
  exit 1
}

result=$(trim "$(bundle exec vagrant run primary hostname)")

[[ 'primary.vagrant.devcommands' == "${result}" ]] || {
  echo 'Passing default box as argv not working...'
  echo "Got result: '${result}'"
  exit 1
}

result=$(trim "$(bundle exec vagrant run secondary hostname)")

[[ 'secondary.vagrant.devcommands' == "${result}" ]] || {
  echo 'Box passed using argv not taking precedence over configuration...'
  echo "Got result: '${result}'"
  exit 1
}

## CHAINS
result=$(trim "$(bundle exec vagrant run chainecho --first="initial" --second="initial" | tr -d '\r\n')")
expect_1='[primary.vagrant.devcommands param initial]'
expect_2='[primary.vagrant.devcommands initial initial]'
expect_3='[primary.vagrant.devcommands param param]'

[[ "${expect_1}${expect_2}${expect_3}" == "${result}" ]] || {
  echo 'Chain argv configuration did not take precedence over argv...'
  echo "Got result: '${result}'"
  exit 1
}

echo 'Success!'
