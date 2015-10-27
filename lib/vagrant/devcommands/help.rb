module VagrantPlugins
  module DevCommands
    # Defines the help output
    #
    # Printed when running "vagrant run" without a command
    class Help
      def self.display
        if Definer.commands.empty?
          puts 'No commands defined!'
          return
        end

        display_header
        display_commands
      end

      class << self
        private

        def display_commands
          pad_to = Definer.commands.keys.map(&:length).max

          Definer.commands.each do |name, command|
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
