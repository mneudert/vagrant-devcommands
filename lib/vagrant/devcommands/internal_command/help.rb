module VagrantPlugins
  module DevCommands
    module InternalCommand
      # Internal "help" command
      class Help
        SPEC = {
          desc: 'display this help message',
          name: 'help'
        }

        def initialize(registry)
          @registry = registry
        end

        def execute
          if @registry.commands.empty?
            puts 'No commands defined!'
            return
          end

          display_help_header
          display_help_commands
        end

        private

        def collect_commands
          @registry.commands.merge VagrantPlugins::DevCommands::Internal::SPECS
        end

        def display_help_commands
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

        def display_help_header
          puts 'Usage: vagrant run [box] <command>'
          puts ''
          puts 'Available commands:'
        end
      end
    end
  end
end
