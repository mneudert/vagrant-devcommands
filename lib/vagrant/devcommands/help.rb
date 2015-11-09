module VagrantPlugins
  module DevCommands
    # Defines the help output
    #
    # Printed when running "vagrant run" without a command
    class Help
      def self.display(registry)
        if registry.commands.empty?
          puts 'No commands defined!'
          return
        end

        display_header
        display_commands(registry)
      end

      class << self
        private

        def display_commands(registry)
          pad_to = registry.commands.keys.map(&:length).max

          registry.commands.each do |name, command|
            if command.key?(:desc)
              puts "     #{name.ljust(pad_to)}   #{command[:desc]}"
            else
              puts "     #{name}"
            end
          end
        end

        def display_header
          puts 'Usage: vagrant run [box] <command>'
          puts ''
          puts 'Available commands:'
        end
      end
    end
  end
end
