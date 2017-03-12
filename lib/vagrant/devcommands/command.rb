module VagrantPlugins
  module DevCommands
    # Defines the executable vagrant command
    class Command < Vagrant.plugin(2, :command)
      UTIL = VagrantPlugins::DevCommands::Util

      def self.synopsis
        'runs vagrant commands from a Commandfile'
      end

      def initialize(argv, env)
        @registry = Registry.new(env)

        super(argv, env)
      end

      def execute
        return 127 unless read_commandfile

        command = argv_command

        return 127 unless check_command(command)

        return run_internal(command) if @registry.reserved_command?(command)

        run @registry.commands[command]
      end

      private

      attr_accessor :registry

      def check_command(command)
        unless command
          run_internal('help')
          return false
        end

        unless @registry.valid_command?(command)
          display_error("Invalid command \"#{command}\"!")
          run_internal('help', ['--commands'])

          return false
        end

        true
      end

      def argv_command
        return nil if @argv.empty?

        command = @argv[0].to_s
        command = @argv[1].to_s if UTIL.machine_name?(@argv[1].to_s,
                                                      @env.machine_index)

        command
      end

      def display_error(msg)
        @env.ui.error msg
        @env.ui.error ''
      end

      def read_commandfile
        commandfile = CommandFile.new(@env)

        unless commandfile.exist?
          @env.ui.error 'Missing Commandfile'

          return false
        end

        @registry.read_commandfile(commandfile)

        true
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

      def run_argv
        argv = @argv.dup

        argv.shift if UTIL.machine_name?(argv[0].to_s, @env.machine_index)
        argv.shift
        argv
      end

      def run_box(cmd)
        box = nil
        box = cmd.box.to_s if cmd.box
        box = @argv[0] if UTIL.machine_name?(@argv[0].to_s, @env.machine_index)

        box
      end

      def run_internal(command, args = nil)
        Internal.new(@env, @registry).run(command, args || run_argv)
      end

      def run_script(command, argv)
        command.run_script(argv)
      rescue KeyError => e
        param = e.message.match(/{(.+)}/).captures.first

        run_script_error(command.name, "missing parameter '#{param}'")
      rescue OptionParser::InvalidOption => e
        run_script_error(command.name, "invalid parameter '#{e.args.first}'")
      end

      def run_script_error(command, error)
        display_error("Could not execute #{command}: #{error}!")
        run_internal('help', [command])

        nil
      end
    end
  end
end
