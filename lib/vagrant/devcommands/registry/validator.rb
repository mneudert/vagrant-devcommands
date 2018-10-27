module VagrantPlugins
  module DevCommands
    class Registry
      # Registry entry validator
      class Validator
        def initialize(messager)
          @messager = messager
        end

        def validate_entries(registry)
          validate_chains(registry)
          validate_command_aliases(registry)
        end

        private

        # rubocop:disable Metrics/MethodLength
        def validate_chains(registry)
          registry.chains.all? do |chain, chain_def|
            chain_def.commands.each do |element|
              next unless element.is_a?(Hash)
              next if registry.valid_command?(element[:command])

              @messager.def_ignored('chain_missing_command',
                                    chain: chain,
                                    command: element)

              registry.chains.delete(chain)

              break
            end
          end
        end
        # rubocop:enable Metrics/MethodLength

        def validate_command_aliases(registry)
          registry.command_aliases.all? do |command_alias, command_alias_def|
            cmd = command_alias_def.command

            next if registry.valid_command?(cmd) || registry.valid_chain?(cmd)

            @messager.def_ignored('command_alias_missing_command',
                                  command_alias: command_alias,
                                  command: cmd)

            registry.command_aliases.delete(command_alias)
          end
        end
      end
    end
  end
end
