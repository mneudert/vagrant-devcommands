# Changelog

## v0.6.0 (2016-05-05)

- Enhancements
  - Command usage now displays the correct parameter syntax
  - Command usage always displays mandatory parameters before optional ones
  - Error output (i.e. "missing Commandfile") is now printed using
    the configured ui class (allows colored output)
  - Global commands can be defined using a file
    named `.vagrant.devcommands` located under `Dir.home()`
  - Invalid parameters are displayed in the error message
  - Missing parameters are displayed in the error message
  - Parameter wrapping is only done if a value is passed
    or a default (at least empty string) is configured
  - Warnings about using internal command names or missing scripts are now
    printed using the configured ui class (allows colored output)

## v0.5.0 (2015-03-21)

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
