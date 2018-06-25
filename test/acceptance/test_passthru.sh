result=$(trim "$(bundle exec vagrant run passthruecho --named=empty)")

[[ "${result}" == '[primary.vagrant.devcommands empty ]' ]] || {
  echo 'Empty passthru parameter not empty...'
  echo "Got result: '${result}'"
  exit 1
}

result=$(trim "$(bundle exec vagrant run passthruecho --named=works --with --all=values)")

[[ "${result}" == '[primary.vagrant.devcommands works --with --all=values]' ]] || {
  echo 'Passthru parameter not passing values...'
  echo "Got result: '${result}'"
  exit 1
}
