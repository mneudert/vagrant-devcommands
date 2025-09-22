result=$(trim "$(bundle exec vagrant run dubble 2>&1)")

[[ ${result} == *'Did you mean this'*'doubleecho'* ]] || {
	echo 'Did-you-mean failed to return single alternative...'
	echo "Got result: '${result}'"
	exit 1
}

result=$(trim "$(bundle exec vagrant run multi_alt 2>&1)")

[[ ${result} == *'Did you mean one of these'*'multi_alternative_1'*'multi_alternative_2'* ]] || {
	echo 'Did-you-mean failed to return multiple alternatives...'
	echo "Got result: '${result}'"
	exit 1
}
