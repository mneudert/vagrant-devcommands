module VagrantPlugins
  module DevCommands
    # Vagrant command registry
    class Registry
      attr_accessor :commands

      def initialize
        @commands = {}
      end

      def read_commandfile(commandfile)
        commandfile.import

        @commands = Definer.commands
      end

      def valid_command?(command)
        @commands.include? command
      end
    end
  end
end
