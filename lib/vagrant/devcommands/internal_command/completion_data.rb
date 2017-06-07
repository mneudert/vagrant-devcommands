module VagrantPlugins
  module DevCommands
    module InternalCommand
      # Internal "completion-data" command
      class CompletionData
        def initialize(env, registry)
          @env      = env
          @registry = registry
        end

        def execute(argv)
          return if @registry.commands.empty?

          command  = VagrantPlugins::DevCommands::Util.argv_command(argv, @env)
          compdata =
            if command.nil?
              command_completion
            else
              argument_completion(command)
            end

          @env.ui.info(compdata, new_line: false)
        end

        private

        def argument_completion(command)
          spec = registry_spec(command)

          return '' if spec.nil?

          (spec.flags.keys + spec.parameters.keys).sort.join(' ')
        end

        def command_completion
          (
            @registry.chains.keys +
            @registry.commands.keys +
            VagrantPlugins::DevCommands::Registry::RESERVED_COMMANDS
          ).sort.join(' ')
        end

        def registry_spec(name)
          return nil if @registry.reserved_command?(name)
          return @registry.commands[name] if @registry.valid_command?(name)

          nil
        end
      end
    end
  end
end
