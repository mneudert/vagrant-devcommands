module VagrantPlugins
  module DevCommands
    module InternalCommand
      # Internal "help" command
      class Help
        UTIL     = VagrantPlugins::DevCommands::Util
        MESSAGES = VagrantPlugins::DevCommands::Messages

        def initialize(env, registry)
          @env      = env
          @registry = registry
        end

        def execute(argv)
          return message(:no_commands) if @registry.commands.empty?

          command = argv[0]

          return plugin_help(command) unless @registry.valid_command?(command)
          return internal_help(command) if @registry.reserved_command?(command)

          command_help(command)
        end

        private

        def command_help(command)
          model = @registry.commands[command]

          command_help_header(command)
          command_help_arguments(model.parameters, 'Parameters')
          command_help_arguments(model.flags, 'Flags')
          command_help_body(model.help)
        end

        def command_help_arguments(arguments, title)
          return if arguments.nil?

          @env.ui.info ''
          @env.ui.info "#{title}:"

          command_help_arguments_body(arguments)
        end

        def command_help_arguments_body(arguments)
          pad_to = UTIL.pad_to(arguments)

          arguments.sort.each do |name, options|
            @env.ui.info UTIL.padded_columns(pad_to, name, options[:desc])
          end
        end

        def command_help_body(help)
          @env.ui.info ''

          if help.nil?
            message(:no_help)
          else
            @env.ui.info help.strip
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

        def internal_commands
          VagrantPlugins::DevCommands::Internal::COMMANDS
        end

        def internal_help(command)
          internal_help_header(command)

          @env.ui.info ''
          @env.ui.info internal_commands[command].help.strip
        end

        def internal_help_header(command)
          spec  = internal_commands[command]
          usage = spec.usage % { command: command }

          @env.ui.info "Usage: #{usage}"
        end

        def message(msg)
          MESSAGES.public_send(msg, &@env.ui.method(:info))
        end

        def plugin_help(command)
          message(:plugin_usage) unless '--commands' == command

          pad_to = UTIL.max_pad([internal_commands,
                                 @registry.commands,
                                 @registry.chains])

          plugin_help_commands('Available', @registry.commands, pad_to)
          plugin_help_commands('Internal', internal_commands, pad_to)
          plugin_help_chains(@registry.chains, pad_to)

          message(:plugin_usage_info) unless '--commands' == command
        end

        def plugin_help_chains(chains, pad_to)
          return if chains.empty?

          @env.ui.info ''
          @env.ui.info 'Command chains:'

          chains.sort.each do |name, chain|
            @env.ui.info UTIL.padded_columns(pad_to, name, chain.desc)
          end
        end

        def plugin_help_commands(type, commands, pad_to)
          return if commands.empty?

          @env.ui.info ''
          @env.ui.info "#{type} commands:"

          commands.sort.each do |name, command|
            @env.ui.info UTIL.padded_columns(pad_to, name, command.desc)
          end
        end

        def usage_params(usage, command)
          [
            usage,
            UTIL.collect_mandatory_params(command.parameters || {}),
            UTIL.collect_optional_params(command.parameters || {}),
            UTIL.collect_flags(command.flags || {})
          ].flatten.compact.join(' ').strip
        end
      end
    end
  end
end
