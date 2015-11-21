module VagrantPlugins
  module DevCommands
    # Vagrant command registry
    class Registry
      attr_accessor :commands

      def initialize
        @commands = {}
      end

      def read_commandfile(commandfile)
        contents = commandfile.path.read

        instance_eval(contents)
      end

      def valid_command?(command)
        @commands.include? command
      end

      private

      def command(name, options)
        if options.is_a?(String)
          @commands[name] = { script: options }
        else
          @commands[name] = options
        end
      end
    end
  end
end
