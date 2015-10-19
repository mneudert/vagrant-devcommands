# Vagrant DevCommands

Runs vagrant commands from a Commandfile.


## Usage

### Command Definition

Add to a `Commandfile` besides your `Vagrantfile`:

```ruby
VagrantDevCommands.define 'with_options', box: :my_box, command: 'hostname'
VagrantDevCommands.define 'without_otions', 'hostname'
```


### Command Listing

```shell
vagrant run
```


### Command Execution

```shell
# single-vm environment
# or multi-vm environment with :box option
vagrant run your_command

# multi-vm environment
vagrant run your_box your_command
```


## Notes for Windows Users

### SSH

If you are using this plugin on a Windows host system, please make sure your
regular `vagrant ssh [box]` succeeds. In some cases you may need to add the
`ssh.exe` (i.e. from a git installation) manually to your `%PATH%`.

### Command Definition

When using multi-line commands you probably need to define your command using
a sigil notation like the following:

```ruby
VagrantDevCommands.define 'long_running_task',
    command: %(cd /path/to/somewhere \
                  && echo "starting long running task" \
                  && ./long_running_task.sh \
                  && echo "finished long running task")
```

Using a quote delimited command definition might otherwise result in not that
helpful error messages about a bad shell command.

It might also help to double check the line endings in your Commandfile are set
unix-style (`\n`) and not windows-style (`\r\n`) if you get errors when running
your commands.


## License

Licensed under the [MIT license](http://opensource.org/licenses/MIT).
