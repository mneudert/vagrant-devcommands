module VagrantPlugins
  module DevCommands
    module Runner
      # Command runner
      class Command
        UTIL = VagrantPlugins::DevCommands::Util

        def initialize(plugin, argv, env, registry)
          @plugin   = plugin
          @argv     = argv
          @env      = env
          @registry = registry
        end

        def run(command)
          argv    = run_argv
          machine = run_machine(command)
          script  = run_script(command, argv)

          return 2 unless script

          @plugin.proxy_with_target_vms(machine, single_target: true) do |vm|
            env = vm.action(:ssh_run,
                            ssh_opts: { extra_args: ['-q'] },
                            ssh_run_command: script)

            return env[:ssh_run_exit_status] || 0
          end
        end

        private

        def run_argv
          argv = @argv.dup

          argv.shift if UTIL.machine_name?(argv[0].to_s, @env.machine_index)
          argv.shift
          argv
        end

        def run_machine(cmd)
          machine = nil
          machine = cmd.machine.to_s if cmd.machine
          machine = @argv[0] if UTIL.machine_name?(@argv[0].to_s,
                                                   @env.machine_index)

          machine
        end

        def run_script(command, argv)
          command.run_script(argv)
        rescue KeyError => e
          param = e.message.match(/{(.+)}/).captures.first

          script_error(command.name, 'missing_parameter', param)
        rescue OptionParser::InvalidOption => e
          script_error(command.name, 'invalid_parameter', e.args.first)
        end

        def script_error(command, type, detail)
          error = I18n.t("vagrant_devcommands.runner.#{type}", detail: detail)

          raise I18n.t('vagrant_devcommands.runner.script_error',
                       command: command,
                       error:   error)
        end
      end
    end
  end
end
