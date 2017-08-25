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
