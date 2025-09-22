result=$(trim "$(bundle exec vagrant run hostname_alias)")

[[ ${result} == 'primary.vagrant.devcommands' ]] || {
	echo 'Default machine not used for command alias...'
	echo "Got result: '${result}'"
	exit 1
}

result=$(trim "$(bundle exec vagrant run primary hostname_alias)")

[[ ${result} == 'primary.vagrant.devcommands' ]] || {
	echo 'Passing default machine as argv not working for command alias...'
	echo "Got result: '${result}'"
	exit 1
}

result=$(trim "$(bundle exec vagrant run secondary hostname_alias)")

[[ ${result} == 'secondary.vagrant.devcommands' ]] || {
	echo 'Machine passed using argv not taking precedence over configuration (command machine)...'
	echo "Got result: '${result}'"
	exit 1
}

result=$(trim "$(bundle exec vagrant run hostname_alias_machine)")

[[ ${result} == 'secondary.vagrant.devcommands' ]] || {
	echo 'Alias machine configured not taking precedence over command machine...'
	echo "Got result: '${result}'"
	exit 1
}

result=$(trim "$(bundle exec vagrant run primary hostname_alias_machine)")

[[ ${result} == 'primary.vagrant.devcommands' ]] || {
	echo 'Machine passed using argv not taking precedence over configuration (command alias machine)...'
	echo "Got result: '${result}'"
	exit 1
}

result=$(trim "$(bundle exec vagrant run doubleecho_alias_full --first="broken" --second="broken")")

[[ ${result} == '[primary.vagrant.devcommands default_first default_second]' ]] || {
	echo 'Alias argv configured not taking precedence over regular argv...'
	echo "Got result: '${result}'"
	exit 1
}

result=$(trim "$(bundle exec vagrant run doubleecho_alias_partial --first="broken" --second="passed_second")")

[[ ${result} == '[primary.vagrant.devcommands default_first passed_second]' ]] || {
	echo 'Argv passed to alias not passed to command...'
	echo "Got result: '${result}'"
	exit 1
}
