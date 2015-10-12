# Vagrant DevCommands

Runs vagrant commands from a Commandfile.


## Command Definition

Add to a `Commandfile` besides your `Vagrantfile`:

```ruby
VagrantPlugins::DevCommands::Definer.define 'with_options', box: :my_box, command: 'hostname'
VagrantPlugins::DevCommands::Definer.define 'without_otions', 'hostname'
```


## Command Listing

```shell
vagrant run
```


## Command Execution

```shell
# single-vm environment
# or multi-vm environment with :box option
vagrant run your_command

# multi-vm environment
vagrant run your_box your_command
```


## License

Licensed under the [MIT license](http://opensource.org/licenses/MIT).
