module VagrantPlugins
  module DevCommands
    # Handles internal commands and their execution.
    class Internal
      def self.run(command)
        puts "Internal command: #{command}"
      end
    end
  end
end
