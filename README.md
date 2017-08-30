# Vagrant DevCommands

Runs vagrant commands from a Commandfile.


## Usage

### Command Listing

```shell
vagrant run
```

### Command Execution

```shell
# single-vm environment
# or multi-vm environment with :machine option
vagrant run your_command

# multi-vm environment
vagrant run your_machine your_command
```

This runs commands or alternatively a command chain with the passed name.

### Command Definition

Add to a `Commandfile` besides your `Vagrantfile`:

```ruby
command 'basic', 'hostname'

command 'with_options',
  machine: :my_machine,
  desc: 'executes "hostname" on the machine "my_machine"',
  script: 'hostname',
  tty: true,
  usage: 'vagrant run %<command>s',
  help: <<-eoh
I am the help message for the command "with_options".
I get displayed when running "vagrant run help with_options".

The usage printed above the help can interpolate the name
of the command name using either %{command} or %<command>s.
eoh
```

_Note_: If you are defining literal `%` (percent sign) in your commands you
have to escape them using a second `%`. For example `date "+%%Y-%%m-%%d"`.

_Note_: Spaces in command names are not supported. Definitions with spaces will
be ignored.

#### Commands with Parameters

Passing additional parameters to a command is (minimally) supported using an
sprintf syntax:

```ruby
command 'with_param',
  parameters: {
    # mandatory parameter with a description
    p_mandatory: { desc: "mandatory parameter to do... stuff!" },

    # parameter with default (implies optional)
    p_default: { default: "always" },

    # parameter with escaping rule
    p_escaped: { escape: { '*' => '\\' }},

    # optional parameter
    p_optional: { optional: true },

    # wrapped option value
    p_wrapped: { wrap: "--and %s wrapped" }

    # parameters with a limited set of allowed values
    # the allowed values are checked prior to escaping/wrapping!
    # optional parameters are only validated if given!
    p_limited: { allowed: ['completely'] }
  },
  script: 'echo %<p_mandatory>s %<p_default>s %<p_escaped>s %<p_optional>s %<p_wrapped>s %<p_limited>s'
```

This allows you to execute the following command:

```shell
# will execute 'echo works always'
vagrant run with_param --p_mandatory works

# will execute 'echo works always like a charm'
vagrant run with_param --p_mandatory works --p_optional "like a charm"

# will execute 'echo works sometimes like a charm --and is wrapped completely'
vagrant run with_param \
    --p_mandatory works \
    --p_default sometimes \
    --p_optional "like a charm" \
    --p_wrapped is
    --p_limited completely
```

For now a command expecting one or more parameters will fail if the user does
not provide them. Any arguments exceeding the number used are silently
discarded.

Escaping rules are defined as `{ "char_to_escape": "char_to_use_as_escape" }`.
These are applied prior to interpolation into the command. Regular ruby escaping
rules apply.

#### Commands with Flags

Every command can be associated with (by definition optional) flags available
for later command interpolation:

```ruby
command 'with_flags',
  flags: {
    f_standard: { desc: "standard flag" },
    f_valued:   { value: "--f_modified" }
  },
  script: 'echo "flags: %<f_standard>s"'
```

This definition allows the following executions:

```shell
# will execute 'echo "flags: "'
vagrant run with_flags

# will execute 'echo "flags: --f_standard"'
vagrant run with_flags --f_standard

# will execute 'echo "flags: --f_modified"'
vagrant run with_flags --f_valued
```

By default a flag gets interpolated as "--#{flagname}". If a value is defined
this value will be interpolated unmodified.

#### Commands defined by Lambda/Proc

You can (more or less) dynamically generate your scripts by defining the
command with a lambda or proc as its script.

```ruby
command 'from_lambda', script: lambda { 'echo "lambda works"' }
command 'from_proc', script: proc { 'echo "proc works"' }
```

These will be evaluated when running the command.

Every rule from regular scripts (parameters, escaping "%", ...) still apply.

### Global Command Definitions

To have commands available even wihout a `Commandfile` you can define the
globally. To do this just create a file named `.vagrant.devcommands` in your
`$HOME` directory.

You can use this command to find the correct path if unsure:

```shell
ruby -e "require 'pathname'; puts Pathname.new(Dir.home).join('.vagrant.devcommands')"
```

Any commands defined there will silently be overwritten by a local definition.

### Chain Definitions

You can define command chains to execute multiple commands in order:

```ruby
chain 'my_chain',
  break_on_error: false,
  commands: [
    { command: 'first' },
    { command: 'second' },
    { command: 'third' }
  ],
  desc: 'Command chain for three commands.',
  help: <<-eoh
I am the help message for the chain "my_chain".
I get displayed when running "vagrant run help my_chain".

The usage printed above the help can interpolate the name
of the command name using %<command>s.
eoh
```

The configured commands will be executed in the order defined.

If one or more of your commands requires parameters all of them have to be
passed to the chain execution.

By default a chain breaks upon the first non-zero return value of any
configured command. To deactivate this behaviour you can set `:break_on_error`
to `false`. Any value other than `false` will stick to the default.

_Note_: Spaces in command names are not supported. Definitions with spaces will
be ignored.

#### Chain Definitions with Pre-Defined Parameters

If required you can modify the arguments given to each chain element by setting
additional/custom argv values for a single chain element:

```ruby
command 'chainecho',
  parameters: { first: {}, second: {} },
  script: 'echo %<first>s %<second>s'

chain 'my_customized_chain',
  commands: [
    { command: 'chainecho', argv: ['--first="param"'] },
    { command: 'chainecho' },
    { command: 'chainecho', argv: ['--first="param"', '--second="param"'] }
  ]
```

Running the chain will execute the following commands:

```shell
> vagrant run my_customized_chain --first="initial" --second="initial"

vagrant run chainecho --first="param" --second="initial"
vagrant run chainecho --first="initial" --second="initial"
vagrant run chainecho --first="param" --second="param"
```

By default every command will be executed using the machine defined by the
command itself or the only one available. You can, however, run the complete
chain against a specific machine using `vagrant run your_machine your_chain`.

#### Chain Definitions with Specific Machines

If required you can modify the machine a box is run on:

```ruby
command 'chainhost',
  script: 'hostname'

chain 'customized_chain_machine',
  commands: [
    { command: 'chainhost' },
    { command: 'chainecho', machine: 'secondary' },
    { command: 'chainecho', machine: 'tertiary' }
  ]
```

Running the chain will execute the following commands:

```shell
> vagrant run customized_chain_machine

vagrant run chainhost
vagrant run secondary chainhost
vagrant run tertiary chainhost
```

This configuration can itself be modified by passing a machine name to run
all chain commands on using  using `vagrant run your_machine your_chain`.

### Abort Parsing inside Commandfile

If you, for whatever reasons, want to abort further parsing of a `Commandfile`
you can simple return from it:

```ruby
command 'foo', script: 'foo'


v_cur = Gem::Version.new(VagrantPlugins::DevCommands::VERSION)
v_min = Gem::Version.new('1.3.3.7')

return if v_cur < v_min


command 'bar', script: 'bar'
```

This example leads to the command `bar` not being available if the currently
installed plugin has a version below `1.3.3.7`.

Please be aware that returning from a global commandfile completely skips
evaluating a local one.

### Experimental: Command Alias Definitions

For commands you want to keep generic but often call with a specific set of
parameter values you can define an alias:

```ruby
command 'customecho',
  parameters: { first: {}, second: {} },
  script: 'echo %<first>s %<second>s'

command_alias 'aliasecho',
  argv:    ['--first="param"', '--second="param"'],
  command: 'customecho',
  desc:    'modified "customecho" command',
  machine: 'non.default'
```

The setting `command` is required, the other options `argv` and `machine` are
optional and used for the actual customization. Any argument configured will
take precedence over the value given to `vagrant run` itself.

### Experimental: Shell Completion

Completion data for your shell is available via internal command:

```shell
# list commands
vagrant run completion-data

# list command flags/parameters
vagrant run completion-data my-command
```


## Notes for Windows Users

### SSH

If you are using this plugin on a Windows host system, please make sure your
regular `vagrant ssh [machine]` succeeds. In some cases you may need to add the
`ssh.exe` (e.g. from a git installation) manually to your `%PATH%`.

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
