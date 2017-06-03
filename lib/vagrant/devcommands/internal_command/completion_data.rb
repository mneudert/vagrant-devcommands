module VagrantPlugins
  module DevCommands
    module InternalCommand
      # Internal "completion-data" command
      class CompletionData
        def initialize(env, registry)
          @env      = env
          @registry = registry
        end

        def execute(_argv)
          return if @registry.commands.empty?

          @env.ui.info(
            (@registry.commands.keys + @registry.chains.keys).sort.join(' '),
            new_line: false
          )
        end
      end
    end
  end
end
