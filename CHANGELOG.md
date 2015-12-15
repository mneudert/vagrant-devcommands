# Changelog

## v0.4.2.dev

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
