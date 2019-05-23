result=$(trim "$(bundle exec vagrant run lambda_zero --param=test)")

[[ "${result}" == 'lambda test' ]] || {
  echo 'Lambda script without arguments not interpolating...'
  echo "Got result: '${result}'"
  exit 1
}

result=$(trim "$(bundle exec vagrant run proc_zero --param=test)")

[[ "${result}" == 'proc test' ]] || {
  echo 'Proc script without arguments not interpolating...'
  echo "Got result: '${result}'"
  exit 1
}

result=$(trim "$(bundle exec vagrant run lambda_argv --param=test)")

[[ "${result}" == 'lambda test' ]] || {
  echo 'Lambda script with arguments not interpolating...'
  echo "Got result: '${result}'"
  exit 1
}

result=$(trim "$(bundle exec vagrant run proc_argv --param=test)")

[[ "${result}" == 'proc test' ]] || {
  echo 'Proc script with arguments not interpolating...'
  echo "Got result: '${result}'"
  exit 1
}
