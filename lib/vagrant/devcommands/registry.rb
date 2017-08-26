module VagrantPlugins
  module DevCommands
    # Registry for definitions from the Commandfile
    class Registry
      RESERVED_COMMANDS = %w[completion-data help version].freeze

      attr_accessor :chains
      attr_accessor :commands
      attr_accessor :command_aliases

      def initialize(env)
        @env      = env
        @messager = Registry::Messager.new(@env)

        @chains          = {}
        @commands        = {}
        @command_aliases = {}
      end

      def available?(name)
        valid_chain?(name) || valid_command?(name) || valid_command_alias?(name)
      end

      def read_commandfile(commandfile)
        register(Commandfile::Reader.new(commandfile, @env).read)

        Registry::Resolver.new(@messager).resolve_naming_conflicts(self)

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
            @messager.def_ignored(e.message, name: entry[:name])
          end
        end
      end

      def register_model(model)
        @chains[model.name]          = model if model.is_a?(Model::Chain)
        @commands[model.name]        = model if model.is_a?(Model::Command)
        @command_aliases[model.name] = model if model.is_a?(Model::CommandAlias)
      end

      def validate_chains
        @chains.all? do |chain, chain_def|
          chain_def.commands.each do |element|
            next unless element.is_a?(Hash)
            next if valid_command?(element[:command])

            msg_args = { chain: chain, command: element }

            @messager.def_ignored('chain_missing_command', msg_args)
            @chains.delete(chain)

            break
          end
        end
      end
    end
  end
end
