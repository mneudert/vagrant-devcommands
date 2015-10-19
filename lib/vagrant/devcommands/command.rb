module VagrantPlugins
  module DevCommands
    # Defines the executable vagrant command
    class Command < Vagrant.plugin(2, :command)
      def self.synopsis
        'runs vagrant commands from a Commandfile'
      end

      def execute
        command = @argv.last

        unless File.exist?(command_file_path)
          return display_error('Missing "Commandfile"')
        end

        import_commands(command_file_path)

        return display_help unless command

        unless valid_command?(command)
          return display_error("Invalid command \"#{command}\"\n")
        end

        run command
      end

      private

      def command_file_path
        File.join @env.cwd, 'Commandfile'
      end

      def display_error(msg)
        puts(msg) && display_help
      end

      def display_help
        Help.display

        # return exit code
        127
      end

      def import_commands(command_file)
        load command_file
      end

      def run(name)
        cmd  = Definer.commands[name]
        argv = run_argv(cmd)

        run_command(cmd, argv)
      end

      def run_argv(cmd)
        argv = @argv.dup
        argv.pop

        if cmd[:box] && argv.empty?
          argv.unshift(cmd[:box].to_s)
        elsif cmd[:box] && 1 == argv.size
          argv[0] = cmd[:box].to_s
        end

        argv
      end

      def run_command(cmd, argv)
        with_target_vms(argv, single_target: true) do |vm|
          env = vm.action(:ssh_run,
                          ssh_opts: { extra_args: ['-q'] },
                          ssh_run_command: cmd[:command])

          return env[:ssh_run_exit_status] || 0
        end
      end

      def valid_command?(command)
        Definer.commands.include? command
      end
    end
  end
end
