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

      def proxy_with_target_vms(names = nil, options = nil, &block)
        # allows public access to protected method with_target_vms
        with_target_vms(names, options, &block)
      end

      private

      def available?(command)
        unless @registry.available?(command)
          display_error("Invalid command \"#{command}\"!")
          run_internal('help', ['--commands'])
        end

        @registry.available?(command)
      end

      def display_error(msg, post_ln = false)
        @env.ui.error msg
        @env.ui.error '' if post_ln
      end

      def non_empty?(command)
        unless command
          run_internal('help')
          return false
        end

        true
      end

      def read_commandfile
        commandfile = Commandfile.new(@env)

        unless commandfile.exist?
          MESSAGES.missing_commandfile(&@env.ui.method(:error))
          MESSAGES.pre_ln(:plugin_readme, &@env.ui.method(:info))

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
        display_error(e.message, true)
        run_internal('help', [command])

        nil
      end

      def run_internal(command, args = nil)
        runner = NAMESPACE_RUNNER::InternalCommand.new(
          self, @argv, @env, @registry
        )

        runner.run(command, args)
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
          NAMESPACE_RUNNER::Command.new(self, @argv, @env, @registry)
        else
          NAMESPACE_RUNNER::Chain.new(self, @argv, @env, @registry)
        end
      end
    end
  end
end
