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
        }

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
          @registry.commands.merge VagrantPlugins::DevCommands::Internal::SPECS
        end

        def command_help(command)
          command_help_header(command)

          puts ''

          if @registry.commands[command].key?(:help)
            puts @registry.commands[command][:help]
          else
            puts 'No detailed help for this command available.'
          end
        end

        def command_help_header(command)
          usage = "vagrant run [box] #{command} [args]"

          if @registry.commands[command].key?(:usage)
            usage = @registry.commands[command][:usage] % { command: command }
          end

          puts "Usage: #{usage}"
        end

        def internal_help(command)
          internal_help_header(command)

          puts ''
          puts VagrantPlugins::DevCommands::Internal::SPECS[command][:help]
        end

        def internal_help_header(command)
          spec  = VagrantPlugins::DevCommands::Internal::SPECS[command]
          usage = spec[:usage] % { command: command }

          puts "Usage: #{usage}"
        end

        def plugin_help
          plugin_help_header
          plugin_help_commands
        end

        def plugin_help_commands
          commands = collect_commands
          pad_to   = commands.keys.map(&:length).max

          commands.each do |name, command|
            if command.key?(:desc)
              puts "     #{name.ljust(pad_to)}   #{command[:desc]}"
            else
              puts "     #{name}"
            end
          end
        end

        def plugin_help_header
          puts 'Usage: vagrant run [box] <command>'
          puts 'Help:  vagrant run help <command>'
          puts ''
          puts 'Available commands:'
        end
      end
    end
  end
end
