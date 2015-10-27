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

        puts 'Usage: vagrant run [box] <command>'
        puts ''
        puts 'Available commands:'

        Definer.commands.each_key do |name|
          puts "     #{name}"
        end
      end
    end
  end
end
