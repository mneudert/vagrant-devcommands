module VagrantPlugins
  module DevCommands
    # Registry for definitions from the Commandfile
    class Registry
      I18N_KEY          = 'vagrant_devcommands.registry'.freeze
      RESERVED_COMMANDS = %w[completion-data help version].freeze

      attr_accessor :chains
      attr_accessor :commands
      attr_accessor :command_aliases

      def initialize(env)
        @env = env

        @chains          = {}
        @commands        = {}
        @command_aliases = {}
      end

      def available?(name)
        valid_chain?(name) || valid_command?(name) || valid_command_alias?(name)
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

      def valid_command_alias?(name)
        @command_aliases.include?(name)
      end

      private

      def register(commandfile_entries)
        modeler = Commandfile::Modeler.new

        commandfile_entries.each do |entry|
          begin
            register_model(modeler.model(entry))
          rescue ArgumentError => e
            warn_def_ignored(e.message, name: entry[:name])
          end
        end
      end

      def register_model(model)
        @chains[model.name]          = model if model.is_a?(Model::Chain)
        @commands[model.name]        = model if model.is_a?(Model::Command)
        @command_aliases[model.name] = model if model.is_a?(Model::CommandAlias)
      end

      def resolve_chain_naming_conflicts
        @chains.keys.each do |name|
          next unless valid_command?(name)

          i18n_msg = 'chain_conflict_command'
          i18n_msg = 'chain_conflict_internal' if reserved_command?(name)

          @env.ui.warn I18n.t("#{I18N_KEY}.#{i18n_msg}", name: name)
          @env.ui.warn I18n.t("#{I18N_KEY}.chain_ignored")

          @chains.delete(name)
        end
      end

      def resolve_command_naming_conflicts
        @commands.keys.each do |name|
          next unless reserved_command?(name)

          warn_def_ignored('command_reserved', name: name)

          @commands.delete(name)
        end
      end

      def resolve_command_alias_naming_conflicts
        @command_aliases.keys.each do |name|
          next unless valid_command?(name) || valid_chain?(name)

          i18n_key = 'command'
          i18n_key = 'chain'    if valid_chain?(name)
          i18n_key = 'internal' if reserved_command?(name)

          i18n_msg = "command_alias_conflict_#{i18n_key}"

          @env.ui.warn I18n.t("#{I18N_KEY}.#{i18n_msg}", name: name)
          @env.ui.warn I18n.t("#{I18N_KEY}.command_alias_ignored")

          @command_aliases.delete(name)
        end
      end

      def resolve_naming_conflicts
        resolve_command_naming_conflicts
        resolve_chain_naming_conflicts
        resolve_command_alias_naming_conflicts
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
