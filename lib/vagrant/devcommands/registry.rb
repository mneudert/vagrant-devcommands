module VagrantPlugins
  module DevCommands
    # Vagrant command registry
    class Registry
      I18N_KEY        = 'vagrant_devcommands.registry'.freeze
      NAMESPACE_MODEL = VagrantPlugins::DevCommands::Model

      RESERVED_COMMANDS = %w(help version).freeze

      attr_accessor :chains
      attr_accessor :commands

      def initialize(env)
        @chains   = {}
        @commands = {}
        @env      = env
      end

      def available?(name)
        valid_command?(name) || valid_chain?(name)
      end

      def read_commandfile(commandfile)
        global = commandfile.path_global
        local  = commandfile.path

        contents  = ''
        contents += "\n" + global.read unless nil == global
        contents += "\n" + local.read unless nil == local

        instance_eval(contents)
        resolve_naming_conflicts
      end

      def reserved_command?(command)
        RESERVED_COMMANDS.include?(command)
      end

      def valid_chain?(chain)
        @chains.include?(chain)
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
        @env.ui.warn I18n.t("#{I18N_KEY}.empty_chain", name: name)
        @env.ui.warn I18n.t("#{I18N_KEY}.def_ignored")
        @env.ui.warn ''
      end

      def reserved_warning(name)
        @env.ui.warn I18n.t("#{I18N_KEY}.reserved", name: name)
        @env.ui.warn I18n.t("#{I18N_KEY}.def_ignored")
        @env.ui.warn ''
      end

      def resolve_naming_conflicts
        @chains.keys.each do |chain|
          next unless @commands.key?(chain)

          @env.ui.warn I18n.t("#{I18N_KEY}.conflict", name: chain)
          @env.ui.warn I18n.t("#{I18N_KEY}.chain_ignored")

          @chains.delete(chain)
        end
      end

      def script_warning(name)
        @env.ui.warn I18n.t("#{I18N_KEY}.no_script", name: name)
        @env.ui.warn I18n.t("#{I18N_KEY}.def_ignored")
        @env.ui.warn ''
      end

      def valid_script?(script)
        return true if script.is_a?(Proc)

        return false unless script.is_a?(String)
        return false if script.empty?

        true
      end
    end
  end
end
