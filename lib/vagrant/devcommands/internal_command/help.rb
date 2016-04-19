module VagrantPlugins
  module DevCommands
    module InternalCommand
      # Internal "help" command
      class Help
        SPEC = {
          desc: 'display this help message',
          name: 'help',
          usage: 'vagrant run %{command} [command]',
          help: <<-eoh
Display the help of the command given as the first argument if defined.
Just like this help for the help command!
eoh
        }.freeze

        def initialize(env, registry)
          @env      = env
          @registry = registry
        end

        def execute(argv)
          return plugin_help_empty if @registry.commands.empty?

          command = argv[0]

          return plugin_help(command) unless @registry.valid_command?(command)
          return internal_help(command) if @registry.reserved_command?(command)

          command_help(command)
        end

        private

        def command_help(command)
          command_help_header(command)

          @env.ui.info ''

          if @registry.commands[command].help.nil?
            @env.ui.info 'No detailed help for this command available.'
          else
            @env.ui.info @registry.commands[command].help
          end
        end

        def command_help_header(command)
          usage = "vagrant run [box] #{command}"
          usage = usage_params(usage, @registry.commands[command])

          unless @registry.commands[command].usage.nil?
            usage = @registry.commands[command].usage % { command: command }
          end

          @env.ui.info "Usage: #{usage}"
        end

        def command_pad_to
          internal_commands
            .merge(@registry.commands)
            .keys
            .map(&:length)
            .max
        end

        def internal_commands
          VagrantPlugins::DevCommands::Internal::COMMANDS
        end

        def internal_help(command)
          internal_help_header(command)

          @env.ui.info ''
          @env.ui.info internal_commands[command].help
        end

        def internal_help_header(command)
          spec  = internal_commands[command]
          usage = spec.usage % { command: command }

          @env.ui.info "Usage: #{usage}"
        end

        def plugin_help(command)
          plugin_help_usage unless '--commands' == command

          pad_to = command_pad_to

          plugin_help_commands('Available', @registry.commands, pad_to)
          plugin_help_commands('Internal', internal_commands, pad_to)
        end

        def plugin_help_commands(type, commands, pad_to)
          @env.ui.info ''
          @env.ui.info "#{type} commands:"

          commands.each do |name, command|
            if command.desc.nil?
              @env.ui.info "     #{name}"
            else
              @env.ui.info "     #{name.ljust(pad_to)}   #{command.desc}"
            end
          end
        end

        def plugin_help_empty
          @env.ui.info 'No commands defined!'
        end

        def plugin_help_usage
          @env.ui.info 'Usage: vagrant run [box] <command>'
          @env.ui.info 'Help:  vagrant run help <command>'
        end

        def usage_params(usage, command)
          return usage if command.parameters.nil?

          [
            usage,
            usage_params_mandatory(command.parameters),
            usage_params_optional(command.parameters)
          ].flatten.compact.join(' ').strip
        end

        def usage_params_mandatory(params)
          params.collect do |key, opts|
            "--#{key}=<#{key}>" unless opts[:optional]
          end
        end

        def usage_params_optional(params)
          params.collect do |key, opts|
            "[--#{key}=<#{key}>]" if opts[:optional]
          end
        end
      end
    end
  end
end
