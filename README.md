# Vagrant DevCommands

Runs vagrant commands from a Commandfile.


## Usage

### Command Definition

Add to a `Commandfile` besides your `Vagrantfile`:

```ruby
command 'basic', 'hostname'

command 'with_options',
    box: :my_box,
    desc: 'executes "hostname" on the box "my_box"',
    script: 'hostname',
    help: <<-eoh
I am the help message for the command "with_options".
I get displayed when running "vagrant run help with_options".
eoh
```

#### Command Definition (parameters)

Passing additional parameters to a command is (minimally) supported using an
sprintf syntax:

```ruby
command 'with_param', script: 'echo "%s"'
```

This allows you to execute the following command:

```shell
# will execute something like 'echo "works"'
vagrant run with_param works
```

For now a command expecting one or more parameters will fail if the user does
not provide them. Any arguments exceeding the number used are silently
discarded.

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
command 'long_running_task',
    script: %(cd /path/to/somewhere \
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
