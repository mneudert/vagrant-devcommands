module VagrantPlugins
  module DevCommands
    # Defines the executable vagrant command
    class Command < Vagrant.plugin(2, :command)
      NAMESPACE_RUNNER = VagrantPlugins::DevCommands::Runner
      MESSAGES         = VagrantPlugins::DevCommands::Messages

      def self.synopsis
        synopsis = VagrantPlugins::DevCommands::SYNOPSIS

        synopsis[0, 1].downcase + synopsis[1..-1]
      end

      def initialize(argv, env)
        @registry = Registry.new(env)

        super(argv, env)
      end

      def execute
        return 127 unless read_commandfile

        command = Util.argv_command(@argv, @env)

        return 127 unless non_empty?(command)
        return 127 unless available?(command)

        return run_internal(command) if @registry.reserved_command?(command)

        run command
      end

      private

      attr_accessor :registry

      def available?(command)
        unless @registry.available?(command)
          display_error("Invalid command \"#{command}\"!")
          run_internal('help', ['--commands'])
        end

        @registry.available?(command)
      end

      def display_error(msg)
        @env.ui.error msg
        @env.ui.error ''
      end

      def non_empty?(command)
        unless command
          run_internal('help')
          return false
        end

        true
      end

      def read_commandfile
        commandfile = CommandFile.new(@env)

        unless commandfile.exist?
          MESSAGES.missing_commandfile(&@env.ui.method(:error))
          MESSAGES.pre_ln(:plugin_usage_info, &@env.ui.method(:info))

          return false
        end

        @registry.read_commandfile(commandfile)

        true
      end

      def run(command)
        runner   = runner_for(command)
        runnable = runnable_for(command)

        runner.run(runnable)
      rescue RuntimeError => e
        display_error(e.message)
        run_internal('help', [runnable])

        nil
      end

      def run_argv
        argv = @argv.dup

        argv.shift if @env.machine_index.include?(argv[0].to_s)
        argv.shift
        argv
      end

      def run_internal(command, args = nil)
        Internal.new(@env, @registry).run(command, args || run_argv)
      end

      def runnable_for(command)
        if @registry.valid_command?(command)
          @registry.commands[command]
        else
          @registry.chains[command]
        end
      end

      def runner_for(command)
        if @registry.valid_command?(command)
          NAMESPACE_RUNNER::Command.new(@argv, @env, @registry)
        else
          NAMESPACE_RUNNER::Chain.new(@argv, @env, @registry)
        end
      end
    end
  end
end
