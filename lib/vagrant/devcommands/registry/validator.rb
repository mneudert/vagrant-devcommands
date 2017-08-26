module VagrantPlugins
  module DevCommands
    class Registry
      # Registry entry validator
      class Validator
        def initialize(messager)
          @messager = messager
        end

        # rubocop:disable Metrics/MethodLength
        def validate_chains(registry)
          registry.chains.all? do |chain, chain_def|
            chain_def.commands.each do |element|
              next unless element.is_a?(Hash)
              next if registry.valid_command?(element[:command])

              @messager.def_ignored('chain_missing_command',
                                    chain:   chain,
                                    command: element)

              registry.chains.delete(chain)

              break
            end
          end
        end
        # rubocop:enable Metrics/MethodLength
      end
    end
  end
end
