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
