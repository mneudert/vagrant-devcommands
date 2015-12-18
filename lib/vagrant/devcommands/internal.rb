module VagrantPlugins
  module DevCommands
    # Handles internal commands and their execution.
    class Internal
      def initialize(registry)
        @registry = registry
      end

      def run(command)
        case command
        when 'help'
          print_help
        when 'version'
          print_version
        end

        0
      end

      private

      def collect_commands
        @registry.commands.merge(
          'help' => {
            desc: 'display this help message',
            name: 'help'
          },
          'version' => {
            desc: 'display currently used the plugin version',
            name: 'version'
          }
        )
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

      def print_version
        puts "vagrant-devcommands, version #{VERSION}"
      end

      def print_help
        if @registry.commands.empty?
          puts 'No commands defined!'
          return
        end

        display_help_header
        display_help_commands
      end
    end
  end
end
