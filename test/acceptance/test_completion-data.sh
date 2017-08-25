result=$(trim "$(bundle exec vagrant run completion-data | wc -w)")

[[ "${result}" == '13' ]] || {
  echo 'Completion data contains unexpected number of return values...'
  echo "Got result: '${result}'"
  exit 1
}
