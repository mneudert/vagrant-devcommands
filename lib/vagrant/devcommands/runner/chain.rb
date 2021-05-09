# frozen_string_literal: true

module VagrantPlugins
  module DevCommands
    module Runner
      # Chain runner
      class Chain
        UTIL = VagrantPlugins::DevCommands::Util

        def initialize(plugin, argv, env, registry)
          @plugin   = plugin
          @argv     = argv
          @env      = env
          @registry = registry
        end

        def run(chain)
          retval = 0

          chain.commands.each do |command_def|
            runnable      = runnable_for(command_def)
            runnable_argv = argv_for(command_def)

            runner = Command.new(@plugin, runnable_argv, @env, @registry)
            retval = runner.run(runnable)

            break if retval.nonzero? && chain.break_on_error?
          end

          retval
        end

        private

        def argv_for(command_def)
          argv = patch_machine(@argv.dup, command_def)

          return argv unless command_def.key?(:argv)
          return argv unless command_def[:argv].is_a?(Array)

          argv + command_def[:argv]
        end

        def patch_machine(argv, command_def)
          return argv unless command_def.key?(:machine)

          if UTIL.machine_name?(argv[0].to_s, @env.machine_index)
            argv
          else
            [command_def[:machine].to_s] + argv
          end
        end

        def runnable_for(command_def)
          @registry.commands[command_def[:command]]
        end
      end
    end
  end
end
