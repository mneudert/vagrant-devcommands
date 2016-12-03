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

          info("#{title}:", true)
          command_help_arguments_body(arguments)
        end

        def command_help_arguments_body(arguments)
          pad_to = UTIL.pad_to(arguments)

          arguments.sort.each do |name, options|
            info(UTIL.padded_columns(pad_to, name, options[:desc]))
          end
        end

        def command_help_body(help)
          return message(:no_help, true) if help.nil?

          info(help.strip, true)
        end

        def command_help_header(command)
          usage = "vagrant run [box] #{command}"
          usage = usage_params(usage, @registry.commands[command])

          unless @registry.commands[command].usage.nil?
            usage = @registry.commands[command].usage % { command: command }
          end

          info("Usage: #{usage}")
        end

        def info(msg, pre_ln = false)
          @env.ui.info '' if pre_ln
          @env.ui.info msg
        end

        def internal_commands
          VagrantPlugins::DevCommands::Internal::COMMANDS
        end

        def internal_help(command)
          internal_help_header(command)
          info(internal_commands[command].help.strip, true)
        end

        def internal_help_header(command)
          spec  = internal_commands[command]
          usage = spec.usage % { command: command }

          info("Usage: #{usage}")
        end

        def message(msg, pre_ln = false)
          if pre_ln
            MESSAGES.pre_ln(msg, &@env.ui.method(:info))
          else
            MESSAGES.public_send(msg, &@env.ui.method(:info))
          end
        end

        def plugin_help(command)
          message(:plugin_usage) unless '--commands' == command

          pad_to = UTIL.max_pad([internal_commands,
                                 @registry.commands,
                                 @registry.chains])

          plugin_help_commands('Available', @registry.commands, pad_to)
          plugin_help_commands('Internal', internal_commands, pad_to)
          plugin_help_chains(@registry.chains, pad_to)

          message(:plugin_usage_info, true) unless '--commands' == command
        end

        def plugin_help_chains(chains, pad_to)
          return if chains.empty?

          info('Command chains:', true)

          chains.sort.each do |name, chain|
            info(UTIL.padded_columns(pad_to, name, chain.desc))
          end
        end

        def plugin_help_commands(type, commands, pad_to)
          return if commands.empty?

          info("#{type} commands:", true)

          commands.sort.each do |name, command|
            info(UTIL.padded_columns(pad_to, name, command.desc))
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
