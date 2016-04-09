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

        def initialize(registry)
          @registry = registry
        end

        def execute(argv)
          if @registry.commands.empty?
            puts 'No commands defined!'
            return
          end

          return plugin_help unless @registry.valid_command?(argv[0])
          return internal_help(argv[0]) if @registry.reserved_command?(argv[0])

          command_help(argv[0])
        end

        private

        def collect_commands
          internal = VagrantPlugins::DevCommands::Internal::COMMANDS

          @registry.commands.merge internal
        end

        def command_help(command)
          command_help_header(command)

          puts ''

          if @registry.commands[command].help.nil?
            puts 'No detailed help for this command available.'
          else
            puts @registry.commands[command].help
          end
        end

        def command_help_header(command)
          usage = "vagrant run [box] #{command}"
          usage = usage_params(usage, @registry.commands[command])

          unless @registry.commands[command].usage.nil?
            usage = @registry.commands[command].usage % { command: command }
          end

          puts "Usage: #{usage}"
        end

        def internal_help(command)
          internal_help_header(command)

          puts ''
          puts VagrantPlugins::DevCommands::Internal::COMMANDS[command].help
        end

        def internal_help_header(command)
          spec  = VagrantPlugins::DevCommands::Internal::COMMANDS[command]
          usage = spec.usage % { command: command }

          puts "Usage: #{usage}"
        end

        def plugin_help
          plugin_help_usage
          plugin_help_commands
        end

        def plugin_help_commands
          puts 'Available commands:'

          commands = collect_commands
          pad_to   = commands.keys.map(&:length).max

          commands.each do |name, command|
            if command.desc.nil?
              puts "     #{name}"
            else
              puts "     #{name.ljust(pad_to)}   #{command.desc}"
            end
          end
        end

        def plugin_help_usage
          puts 'Usage: vagrant run [box] <command>'
          puts 'Help:  vagrant run help <command>'
          puts ''
        end

        def usage_params(usage, command)
          return usage if command.parameters.nil?

          params = command.parameters.collect do |key, opts|
            if opts[:optional]
              "[#{key}]"
            else
              "<#{key}>"
            end
          end

          "#{usage} #{params.join(' ')}"
        end
      end
    end
  end
end
