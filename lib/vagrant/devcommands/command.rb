module VagrantPlugins
  module DevCommands
    # Defines the executable vagrant command
    class Command < Vagrant.plugin(2, :command)
      def self.synopsis
        'runs vagrant commands from a Commandfile'
      end

      def initialize(argv, env)
        @registry = Registry.new

        super(argv, env)
      end

      def execute
        command     = @argv.last
        commandfile = Commandfile.new(@env)

        return display_error('Missing "Commandfile"') unless commandfile.exist?

        @registry.read_commandfile(commandfile)

        return display_help unless command

        unless @registry.valid_command?(command)
          return display_error("Invalid command \"#{command}\"\n")
        end

        run @registry.commands[command]
      end

      private

      attr_accessor :registry

      def display_error(msg)
        puts(msg) && display_help
      end

      def display_help
        Help.display(@registry)

        # return exit code
        127
      end

      def run(command)
        argv = run_argv(command)

        with_target_vms(argv, single_target: true) do |vm|
          env = vm.action(:ssh_run,
                          ssh_opts: { extra_args: ['-q'] },
                          ssh_run_command: command[:script])

          return env[:ssh_run_exit_status] || 0
        end
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
    end
  end
end
