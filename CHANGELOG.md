# Changelog

## v0.11.0 (2017-10-02)

- Enhancements
  - Command aliases can be used to provide multiple ways to call a single
    command including automatically populated arguments
  - Commands can define if they need a tty by using the new `:tty` option

- Backwards incompatible changes
  - By default a command does not use a tty. This potentially breaks commands
    requiring one, e.g. a mysql console command

## v0.10.1 (2017-08-08)

- Bug fixes
  - Vagrant introduced a tty flag for ssh command execution in version `1.9.6`.
    This broke some commands requiring an interactive terminal
    (like a mysql client). This flag is now permanently active to restore the
    function of these commands until the next regular release introduces a
    full per command tty configuration

## v0.10.0 (2017-07-02)

- Enhancements
  - Command alternatives provided by the "did-you-mean" feature no longer
    display the full command list (help)
  - Depending on the internal scoring multiple alternative commands
    will be presented instead of a full command list (help)
  - Minimal data for shell completion is available via the internal
    `completion-data` command
  - Parameters can limit the values you are allowed to pass in
  - Spaces in chain/command names are now officially disallowed. Those
    would have always been broken anyways, but now there is a nice message
    and the commands are excluded from the various listings

- Bug fixes
  - Chain names can no longer conflict with internal commands like `help`
    or `version`. The respective chain definitions are dropped and a warning
    is issued

## v0.9.0 (2017-05-20)

- Enhancements
  - Every command in a chain can specify the machine to be used
  - If an unknown command is requested a possible alternative
    is suggested based on the calculated
    [Jaro-Winkler distance](https://en.wikipedia.org/wiki/Jaro%E2%80%93Winkler_distance)

- Deprecations
  - The configuration parameter `:box` has been renamed to `:machine` to
    match the vagrant naming. Support for the old configuration will be
    dropped in a future version

## v0.8.0 (2017-04-19)

- Enhancements
  - Chains can be defined to execute multiple commands in order
  - Commands can define flags (always optional!) for script interpolation

## v0.7.2 (2017-03-12)

- Bug fixes
  - Machine names passed via argv are properly detected and used
    ([#1](https://github.com/mneudert/vagrant-devcommands/pull/1))

## v0.7.1 (2017-02-15)

- Bug fixes
  - Wrapping of optional parameters should now properly be done only if
    at least an empty string is defined as a default value

## v0.7.0 (2016-09-26)

- Enhancements
  - Parameters are allowed to have a detailed description
  - Parameters values can be escaped before interpolation

## v0.6.0 (2016-05-05)

- Enhancements
  - Command usage now displays the correct parameter syntax
  - Command usage always displays mandatory parameters before optional ones
  - Error output (e.g. "missing Commandfile") is now printed using
    the configured ui class (allows colored output)
  - Global commands can be defined using a file
    named `.vagrant.devcommands` located under `Dir.home()`
  - Invalid parameters are displayed in the error message
  - Missing parameters are displayed in the error message
  - Parameter wrapping is only done if a value is passed
    or a default (at least empty string) is configured
  - Warnings about using internal command names or missing scripts are now
    printed using the configured ui class (allows colored output)

## v0.5.0 (2016-03-21)

- Enhancements
  - Commands can define a detailed help message
  - Commands can define a custom usage string
  - Commands can be defined using a lambda/proc
  - Commands can be defined with additional named parameters to be interpolated
  - Internal commands are included in the command listing (help)
  - Script parameters can be optional

- Backwards incompatible changes
  - Positional parameters have been replaced with named parameters

- Bug fixes
  - Displays actual command name when an error occurs due to missing arguments

## v0.4.2 (2015-12-15)

- Bug fixes
  - Properly detects (missing) command name from argv

## v0.4.1 (2015-12-14)

- Bug fixes
  - Properly handles commands targeting a single box when definition uses symbol for name

## v0.4.0 (2015-12-13)

- Enhancements
  - `vagrant run help` prints the plugin help (same as `vagrant run`)
  - `vagrant run version` prints the currently used plugin version
  - Commands can receive additional parameters from the command line

- Backwards incompatible changes
  - Command names `help` and `version` are reserved for internal usage
  - Depecrated command definer was removed

- Bug fixes
  - Commands without a script display a message and are ignored

## v0.3.0 (2015-11-21)

- Enhancements
  - Commands can be created using `command 'name', 'script'`

- Deprecations
  - Commands defined without the new `command ...` syntax are deprecated

## v0.2.0 (2015-11-02)

- Enhancements
  - Commandfile is read from the path of the loaded Vagrantfile
  - Commandfile is looked up case insensitive (`Commandfile` vs `commandfile`)
  - Descriptions can be set for commands

- Bug fixes
  - Commandfile can be located outside of current working directory

## v0.1.0 (2015-10-16)

- Initial Release
