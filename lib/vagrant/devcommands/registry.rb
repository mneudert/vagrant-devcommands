module VagrantPlugins
  module DevCommands
    # Vagrant command registry
    class Registry
      RESERVED_COMMANDS = %w(help version)

      attr_accessor :commands

      def initialize
        @commands = {}
      end

      def read_commandfile(commandfile)
        contents = commandfile.path.read

        instance_eval(contents)
      end

      def reserved_command?(command)
        RESERVED_COMMANDS.include?(command)
      end

      def valid_command?(command)
        @commands.include?(command) || reserved_command?(command)
      end

      private

      def command(name, options)
        return reserved_warning(name) if reserved_command?(name)

        if options.is_a?(String)
          @commands[name] = { script: options }
        else
          @commands[name] = options
        end

        @commands[name][:name] = name
      end

      def reserved_warning(name)
        puts "The command name '#{name}' is reserved for internal usage."
        puts 'Your definition of it will be ignored.'
        puts ''
      end
    end
  end
end