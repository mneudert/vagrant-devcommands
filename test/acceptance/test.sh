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

[[ "${result}" == 'primary.vagrant.devcommands' ]] || {
  echo 'Default machine not used...'
  echo "Got result: '${result}'"
  exit 1
}

result=$(trim "$(bundle exec vagrant run primary hostname)")

[[ "${result}" == 'primary.vagrant.devcommands' ]] || {
  echo 'Passing default machine as argv not working...'
  echo "Got result: '${result}'"
  exit 1
}

result=$(trim "$(bundle exec vagrant run secondary hostname)")

[[ "${result}" == 'secondary.vagrant.devcommands' ]] || {
  echo 'Machine passed using argv not taking precedence over configuration...'
  echo "Got result: '${result}'"
  exit 1
}

## COMMAND-BOX-NAME-CLASH
result=$(trim "$(bundle exec vagrant run primary)")

[[ "${result}" == 'primary.vagrant.devcommands' ]] || {
  echo 'Configured machine for "command == machine" not used...'
  echo "Got result: '${result}'"
  exit 1
}

result=$(trim "$(bundle exec vagrant run primary primary)")

[[ "${result}" == 'primary.vagrant.devcommands' ]] || {
  echo 'Name passed using argv not used for "command == machine"...'
  echo "Got result: '${result}'"
  exit 1
}

result=$(trim "$(bundle exec vagrant run secondary primary)")

[[ "${result}" == 'secondary.vagrant.devcommands' ]] || {
  echo 'Machine passed using argv not used for "command == machine"...'
  echo "Got result: '${result}'"
  exit 1
}

## CHAINS
result=$(trim "$(bundle exec vagrant run chainecho --first="initial" --second="initial")")
expect_1='[primary.vagrant.devcommands param initial]'
expect_2='[primary.vagrant.devcommands initial initial]'
expect_3='[primary.vagrant.devcommands param param]'

[[ "${result}" == *"${expect_1}"*"${expect_2}"*"${expect_3}"* ]] || {
  echo 'Chain argv configuration did not take precedence over argv...'
  echo "Got result: '${result}'"
  exit 1
}

result=$(trim "$(bundle exec vagrant run secondary chainecho --first="initial" --second="initial")")
expect_1='[secondary.vagrant.devcommands param initial]'
expect_2='[secondary.vagrant.devcommands initial initial]'
expect_3='[secondary.vagrant.devcommands param param]'

[[ "${result}" == *"${expect_1}"*"${expect_2}"*"${expect_3}"* ]] || {
  echo 'Machine passed using argv not taking precedence command over configuration...'
  echo "Got result: '${result}'"
  exit 1
}

result=$(trim "$(bundle exec vagrant run chainmachine)")
expect_1='primary.vagrant.devcommands'
expect_2='secondary.vagrant.devcommands'

[[ "${result}" == *"${expect_1}"*"${expect_2}"* ]] || {
  echo 'Chain machine configuration did not take precedence over command configuration...'
  echo "Got result: '${result}'"
  exit 1
}

result=$(trim "$(bundle exec vagrant run secondary chainmachine)")
expect_1='secondary.vagrant.devcommands'
expect_2='secondary.vagrant.devcommands'

[[ "${result}" == *"${expect_1}"*"${expect_2}"* ]] || {
  echo 'Machine passed using argv not taking precedence chain over configuration...'
  echo "Got result: '${result}'"
  exit 1
}

## DID YOU MEAN?
result=$(trim "$(bundle exec vagrant run dubble 2>&1)")

[[ "${result}" == *'doubleecho'*'Available commands'* ]] || {
  echo 'Did-you-mean failed to list all commands...'
  echo "Got result: '${result}'"
  exit 1
}

result=$(trim "$(bundle exec vagrant run double 2>&1)")

[[ "${result}" == *'doubleecho'* && "${result}" != *'Available commands'* ]] || {
  echo 'Did-you-mean listed all commands despite it should not...'
  echo "Got result: '${result}'"
  exit 1
}

## COMPLETION-DATA
result=$(trim "$(bundle exec vagrant run completion-data | wc -w)")

[[ "${result}" == '8' ]] || {
  echo 'Completion data contains unexpected number of return values...'
  echo "Got result: '${result}'"
  exit 1
}

# finish
echo 'Success!'
