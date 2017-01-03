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
          runner = Command.new(@argv, @env, @registry)

          chain.commands.each do |command|
            retval = runner.run(@registry.commands[command])

            break if retval.nonzero? && chain.break_on_error?
          end

          retval
        end
      end
    end
  end
end
