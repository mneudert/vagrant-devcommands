module VagrantPlugins
  module DevCommands
    # Vagrant command registry
    class Registry
      I18N_KEY          = 'vagrant_devcommands.registry'.freeze
      RESERVED_COMMANDS = %w[completion-data help version].freeze

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
        Commandfile::Reader.new(commandfile).read.each do |entry|
          send(entry[:type], entry[:name], entry[:options])
        end

        resolve_naming_conflicts
        validate_chains
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

      def chain(name, options)
        options            = {} unless options.is_a?(Hash)
        options[:commands] = {} unless options.key?(:commands)
        options[:name]     = name

        if options[:commands].empty?
          return warn_def_ignored('chain_empty', name: name)
        end

        if name.include?(' ')
          return warn_def_ignored('chain_name_space', name: name)
        end

        @chains[name] = Model::Chain.new(options)
      end

      # rubocop:disable Metrics/MethodLength
      def command(name, options)
        if reserved_command?(name)
          return warn_def_ignored('command_reserved', name: name)
        end

        if name.include?(' ')
          return warn_def_ignored('command_name_space', name: name)
        end

        options        = { script: options } unless options.is_a?(Hash)
        options[:name] = name

        unless valid_script?(options[:script])
          return warn_def_ignored('command_no_script', name: name)
        end

        @commands[name] = Model::Command.new(options)
      end
      # rubocop:enable Metrics/MethodLength

      def resolve_naming_conflicts
        @chains.keys.each do |chain|
          next unless valid_command?(chain)

          i18n_msg = 'conflict_command'
          i18n_msg = 'conflict_internal' if reserved_command?(chain)

          @env.ui.warn I18n.t("#{I18N_KEY}.#{i18n_msg}", name: chain)
          @env.ui.warn I18n.t("#{I18N_KEY}.chain_ignored")

          @chains.delete(chain)
        end
      end

      def valid_script?(script)
        return true if script.is_a?(Proc)

        return false unless script.is_a?(String)
        return false if script.empty?

        true
      end

      def validate_chains
        @chains.all? do |chain, chain_def|
          chain_def.commands.each do |element|
            next unless element.is_a?(Hash)
            next if valid_command?(element[:command])

            warn_def_ignored('chain_missing_command',
                             chain: chain, command: element)

            @chains.delete(chain)

            break
          end
        end
      end

      def warn_def_ignored(message, args)
        @env.ui.warn I18n.t("#{I18N_KEY}.#{message}", args)
        @env.ui.warn I18n.t("#{I18N_KEY}.def_ignored")
        @env.ui.warn ''
      end
    end
  end
end
