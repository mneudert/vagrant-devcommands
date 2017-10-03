module VagrantPlugins
  module DevCommands
    # Defines the executable vagrant command
    class Command < Vagrant.plugin(2, :command)
      I18N_KEY = 'vagrant_devcommands.'.freeze

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
          display_alternatives(command)
        end

        @registry.available?(command)
      end

      def display_alternatives(command)
        alternatives = Util.did_you_mean(command, @registry)
        alternatives = alternatives.select { |_k, v| v > 0.8 }

        return false if alternatives.empty?

        if alternatives.length == 1
          display_error(I18n.t("#{I18N_KEY}.did_you_mean_single"), true)
        else
          display_error(I18n.t("#{I18N_KEY}.did_you_mean_multi"), true)
        end

        alternatives.sort.each { |(k, _v)| display_error("        #{k}") }
      end

      def display_error(msg, pre_ln = false, post_ln = false)
        @env.ui.error '' if pre_ln
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
          Messages.missing_commandfile(&@env.ui.method(:error))
          Messages.pre_ln(:plugin_readme, &@env.ui.method(:info))

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
        display_error(e.message, false, true)
        run_internal('help', [command])

        nil
      end

      def run_internal(command, args = nil)
        runner = Runner::InternalCommand.new(
          self, @argv, @env, @registry
        )

        runner.run(command, args)
      end

      def runnable_for(name)
        if @registry.valid_chain?(name)
          @registry.chains[name]
        elsif @registry.valid_command_alias?(name)
          @registry.command_aliases[name]
        else
          @registry.commands[name]
        end
      end

      def runner_for(name)
        if @registry.valid_chain?(name)
          Runner::Chain.new(self, @argv, @env, @registry)
        elsif @registry.valid_command_alias?(name)
          Runner::CommandAlias.new(self, @argv, @env, @registry)
        else
          Runner::Command.new(self, @argv, @env, @registry)
        end
      end
    end
  end
end
