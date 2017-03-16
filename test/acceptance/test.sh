#!/usr/bin/env bash

# change cwd to current script dir
cd ${0%/*}

# setup global configuration
export BUNDLE_GEMFILE='../../Gemfile'
export VAGRANT_I_KNOW_WHAT_IM_DOING_PLEASE_BE_QUIET='true'

# prepare tests
echo 'Installing dependencies...'
bundle install > /dev/null

echo 'Starting containers...'
bundle exec vagrant up > /dev/null

# run tests
echo 'Running tests...'
bundle exec vagrant run primary hostname
bundle exec vagrant run secondary hostname
