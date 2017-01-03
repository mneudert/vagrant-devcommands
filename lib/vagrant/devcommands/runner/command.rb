module VagrantPlugins
  module DevCommands
    module Runner
      # Command runner
      class Command
        def initialize(argv, env, registry)
          @argv     = argv
          @env      = env
          @registry = registry
        end

        def run(command)
          argv   = run_argv
          box    = run_box(command)
          script = run_script(command, argv)

          return 2 unless script

          with_target_vms(box, single_target: true) do |vm|
            env = vm.action(:ssh_run,
                            ssh_opts: { extra_args: ['-q'] },
                            ssh_run_command: script)

            return env[:ssh_run_exit_status] || 0
          end
        end

        private

        def run_argv
          argv = @argv.dup

          argv.shift if @env.machine_index.include?(argv[0].to_s)
          argv.shift
          argv
        end

        def run_box(cmd)
          return cmd.box.to_s if cmd.box
          return @argv[0].to_s if @env.machine_index.include?(@argv[0].to_s)

          nil
        end

        def run_script(command, argv)
          command.run_script(argv)
        rescue KeyError => e
          param = e.message.match(/{(.+)}/).captures.first

          script_error(command.name, "missing parameter '#{param}'")
        rescue OptionParser::InvalidOption => e
          script_error(command.name, "invalid parameter '#{e.args.first}'")
        end

        def script_error(command, error)
          raise "Could not execute #{command}: #{error}!"
        end
      end
    end
  end
end
