module VagrantPlugins
  module DevCommands
    module Runner
      # Chain runner
      class Chain
        def initialize(argv, env, registry)
          @argv     = argv
          @env      = env
          @registry = registry
        end

        def run(chain)
          retval = 0

          chain.commands.each do |command_def|
            runnable      = runnable_for(command_def)
            runnable_argv = argv_for(command_def)

            runner = Command.new(runnable_argv, @env, @registry)
            retval = runner.run(runnable)

            break if retval.nonzero? && chain.break_on_error?
          end

          retval
        end

        private

        def argv_for(_command_def)
          @argv
        end

        def runnable_for(command_def)
          @registry.commands[command_def]
        end
      end
    end
  end
end
