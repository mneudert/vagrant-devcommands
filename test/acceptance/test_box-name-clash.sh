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
