# Changelog

## v0.4.0.dev

- Backwards incompatible changes
  - Command names `help` and `version` are reserved for internal usage
  - Depecrated command definer was removed

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
