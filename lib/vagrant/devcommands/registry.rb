# frozen_string_literal: true

module VagrantPlugins
  module DevCommands
    # Registry for definitions from the Commandfile
    class Registry
      RESERVED_COMMANDS = %w[completion-data help version].freeze

      attr_accessor :chains, :commands, :command_aliases

      def initialize(env)
        @env      = env
        @messager = Registry::Messager.new(@env)

        @chains          = {}
        @commands        = {}
        @command_aliases = {}

        @duplicates = {
          'chains' => [],
          'commands' => [],
          'command_aliases' => []
        }
      end

      def available?(name)
        valid_chain?(name) || valid_command?(name) || valid_command_alias?(name)
      end

      def read_commandfile(commandfile)
        register(Commandfile::Reader.new(commandfile, @env).read)

        Registry::Resolver.new(@messager).resolve_naming_conflicts(self)
        Registry::Validator.new(@messager).validate_entries(self)
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

      def check_model(model, entry)
        speccheck_model(model, entry)
        dupcheck_model(model)
      end

      def dupcheck_model(model)
        type         = model_attr(model)
        type_attr    = "@#{type}"
        type_entries = instance_variable_get(type_attr)

        return unless type_entries[model.name]
        return if @duplicates[type].include?(model.name)

        @messager.def_duplicate(what: model_name(model), name: model.name)
        @duplicates[type] << model.name
      end

      def model_attr(model)
        case model
        when Model::Chain
          'chains'
        when Model::Command
          'commands'
        when Model::CommandAlias
          'command_aliases'
        end
      end

      def model_name(model)
        case model
        when Model::Chain
          'chain'
        when Model::Command
          'command'
        when Model::CommandAlias
          'command alias'
        end
      end

      def register(commandfile_entries)
        modeler = Commandfile::Modeler.new

        commandfile_entries.each do |entry|
          begin
            model = modeler.model(entry)

            check_model(model, entry)
            register_model(model)
          rescue ArgumentError => e
            @messager.def_ignored(e.message, name: entry[:name])
          end
        end
      end

      def register_model(model)
        type         = model_attr(model)
        type_attr    = "@#{type}"
        type_entries = instance_variable_get(type_attr)

        type_entries[model.name] = model

        instance_variable_set(type_attr, type_entries)
      end

      def speccheck_model(model, spec)
        return unless spec[:options].is_a?(Hash)

        model_attrs = model.instance_variables
        spec_attrs  = spec[:options].keys.map { |k| :"@#{k}" }

        return if (spec_attrs - model_attrs).empty?

        @messager.unknown_options(what: model_name(model), name: model.name)
      end
    end
  end
end
