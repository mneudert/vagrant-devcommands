module VagrantPlugins
  module DevCommands
    # Vagrant command registry
    class Registry
      RESERVED_COMMANDS = %w(help version).freeze

      attr_accessor :commands

      def initialize(env)
        @commands = {}
        @env      = env
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

        options = { script: options } unless options.is_a?(Hash)

        return script_warning(name) unless options.key?(:script)

        options[:name] = name

        @commands[name] = CommandDef.new(options)
      end

      def script_warning(name)
        @env.ui.warn "The command '#{name}' has no script defined to execute."
        @env.ui.warn 'Your definition of it will be ignored.'
        @env.ui.warn ''
      end

      def reserved_warning(name)
        @env.ui.warn(
          "The command name '#{name}' is reserved for internal usage."
        )

        @env.ui.warn 'Your definition of it will be ignored.'
        @env.ui.warn ''
      end
    end
  end
end
