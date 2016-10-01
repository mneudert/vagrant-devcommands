module VagrantPlugins
  module DevCommands
    # Vagrant command registry
    class Registry
      NAMESPACE_MODEL = VagrantPlugins::DevCommands::Model

      RESERVED_COMMANDS = %w(help version).freeze

      attr_accessor :chains
      attr_accessor :commands

      def initialize(env)
        @chains   = {}
        @commands = {}
        @env      = env
      end

      def read_commandfile(commandfile)
        global = commandfile.path_global
        local  = commandfile.path

        contents  = ''
        contents += "\n" + global.read unless nil == global
        contents += "\n" + local.read unless nil == local

        instance_eval(contents)
        warn_naming_conflicts
      end

      def reserved_command?(command)
        RESERVED_COMMANDS.include?(command)
      end

      def valid_command?(command)
        @commands.include?(command) || reserved_command?(command)
      end

      private

      def chain(name, options = nil)
        options            = {} unless options.is_a?(Hash)
        options[:commands] = {} unless options.key?(:commands)

        return empty_chain_warning(name) if options[:commands].empty?

        options[:name] = name

        @chains[name] = NAMESPACE_MODEL::Chain.new(options)
      end

      def command(name, options = nil)
        return reserved_warning(name) if reserved_command?(name)

        options = { script: options } unless options.is_a?(Hash)

        return script_warning(name) unless valid_script?(options[:script])

        options[:name] = name

        @commands[name] = NAMESPACE_MODEL::Command.new(options)
      end

      def empty_chain_warning(name)
        @env.ui.warn "The chain '#{name}' has no commands associated."
        @env.ui.warn 'Your definition of it will be ignored.'
        @env.ui.warn ''
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

      def valid_script?(script)
        return true if script.is_a?(Proc)

        return false unless script.is_a?(String)
        return false if script.empty?

        true
      end

      def warn_naming_conflicts
        @chains.keys.each do |chain|
          next unless @commands.key?(chain)

          @env.ui.warn(
            "The name '#{chain}' is used for both a command and a chain."
          )

          @env.ui.warn(
            'Your chain definition will be ignored in favor of the command'
          )
        end
      end
    end
  end
end
