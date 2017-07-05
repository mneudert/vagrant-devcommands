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
        register(Commandfile::Reader.new(commandfile).read)

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

      def register(commandfile_entries)
        modeler = Commandfile::Modeler.new

        commandfile_entries.each do |entry|
          begin
            model = modeler.model(entry)

            @chains[entry[:name]]   = model if model.is_a?(Model::Chain)
            @commands[entry[:name]] = model if model.is_a?(Model::Command)
          rescue ArgumentError => e
            warn_def_ignored(e.message, name: entry[:name])
          end
        end
      end

      def resolve_chain_naming_conflicts
        @chains.keys.each do |chain|
          next unless valid_command?(chain)

          i18n_msg = 'conflict_command'
          i18n_msg = 'conflict_internal' if reserved_command?(chain)

          @env.ui.warn I18n.t("#{I18N_KEY}.#{i18n_msg}", name: chain)
          @env.ui.warn I18n.t("#{I18N_KEY}.chain_ignored")

          @chains.delete(chain)
        end
      end

      def resolve_command_naming_conflicts
        @commands.keys.each do |command|
          next unless reserved_command?(command)

          warn_def_ignored('command_reserved', name: command)

          @commands.delete(command)
        end
      end

      def resolve_naming_conflicts
        resolve_command_naming_conflicts
        resolve_chain_naming_conflicts
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
