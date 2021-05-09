# frozen_string_literal: true

module VagrantPlugins
  module DevCommands
    module Runner
      # Command alias runner
      class CommandAlias
        UTIL = VagrantPlugins::DevCommands::Util

        def initialize(plugin, argv, env, registry)
          @plugin   = plugin
          @argv     = argv
          @env      = env
          @registry = registry
        end

        def run(command_alias)
          runnable      = runnable_for(command_alias)
          runnable_argv = argv_for(command_alias)

          Command.new(@plugin, runnable_argv, @env, @registry).run(runnable)
        end

        private

        def argv_for(command_alias)
          argv = @argv.dup
          argv = patch_machine(argv, command_alias)
          argv = patch_command(argv, command_alias)

          return argv unless command_alias.argv.is_a?(Array)

          argv + command_alias.argv
        end

        def patch_command(argv, command_alias)
          index = 0
          index = 1 if UTIL.machine_name?(argv[0].to_s, @env.machine_index)

          argv[index] = command_alias.command
          argv
        end

        def patch_machine(argv, command_alias)
          return argv if UTIL.machine_name?(argv[0].to_s, @env.machine_index)

          argv.unshift(command_alias.machine) if command_alias.machine
          argv
        end

        def runnable_for(command_alias)
          @registry.commands[command_alias.command]
        end
      end
    end
  end
end
