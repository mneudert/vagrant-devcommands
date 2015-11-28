module VagrantPlugins
  module DevCommands
    # Handles internal commands and their execution.
    class Internal
      def run(command)
        case command
        when 'version'
          print_version
        end

        0
      end

      private

      def print_version
        puts "vagrant-devcommands, version #{VERSION}"
      end
    end
  end
end
