# Vagrant DevCommands

Runs vagrant commands from a Commandfile.


## Command Definition

Add to a `Commandfile` beneath your `Vagrantfile`:

```ruby
Vagrant::DevCommand.define 'with_options', [ with: :options ], 'no code'
Vagrant::DevCommand.define 'without_otions', 'no code'
```


## Command Listing

```shell
vagrant run
```
