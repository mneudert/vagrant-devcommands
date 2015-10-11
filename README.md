# Vagrant DevCommands

Runs vagrant commands from a Commandfile.


## Command Definition

Add to a `Commandfile` besides your `Vagrantfile`:

```ruby
Vagrant::DevCommand.define 'with_options', [ with: :options ], 'no code'
Vagrant::DevCommand.define 'without_otions', 'no code'
```


## Command Listing

```shell
vagrant run
```


## Command Execution

```shell
# single-vm environment
vagrant run your_command

# multi-vm environment
vagrant run your_box your_command
```


## License

Licensed under the [MIT license](http://opensource.org/licenses/MIT).
