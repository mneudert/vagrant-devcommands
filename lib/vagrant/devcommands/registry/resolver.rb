module VagrantPlugins
  module DevCommands
    class Registry
      # Registry conflict resolver
      class Resolver
        def initialize(messager)
          @messager = messager
        end

        def resolve_naming_conflicts(registry)
          resolve_command_naming_conflicts(registry)
          resolve_chain_naming_conflicts(registry)
          resolve_command_alias_naming_conflicts(registry)
        end

        private

        def resolve_chain_naming_conflicts(registry)
          registry.chains.keys.each do |name|
            next unless registry.valid_command?(name)

            i18n_msg = 'chain_conflict_command'

            if registry.reserved_command?(name)
              i18n_msg = 'chain_conflict_internal'
            end

            @messager.chain_ignored(i18n_msg, name)

            registry.chains.delete(name)
          end
        end

        def resolve_command_naming_conflicts(registry)
          registry.commands.keys.each do |name|
            next unless registry.reserved_command?(name)

            @messager.def_ignored('command_reserved', name: name)

            registry.commands.delete(name)
          end
        end

        # rubocop:disable Metrics/MethodLength
        def resolve_command_alias_naming_conflicts(registry)
          registry.command_aliases.keys.each do |name|
            unless registry.valid_command?(name) || registry.valid_chain?(name)
              next
            end

            i18n_key = 'command'
            i18n_key = 'chain'    if registry.valid_chain?(name)
            i18n_key = 'internal' if registry.reserved_command?(name)

            i18n_msg = "command_alias_conflict_#{i18n_key}"

            @messager.command_alias_ignored(i18n_msg, name)

            registry.command_aliases.delete(name)
          end
        end
        # rubocop:enable Metrics/MethodLength
      end
    end
  end
end
