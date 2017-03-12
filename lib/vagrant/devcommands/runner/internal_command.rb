module VagrantPlugins
  module DevCommands
    module Runner
      # Internal command runner
      class InternalCommand
        NAMESPACE_CMD   = VagrantPlugins::DevCommands::InternalCommand
        NAMESPACE_MODEL = VagrantPlugins::DevCommands::Model
        NAMESPACE_SPEC  = VagrantPlugins::DevCommands::InternalSpec

        COMMANDS = {
          'help'    => NAMESPACE_MODEL::Command.new(NAMESPACE_SPEC::HELP),
          'version' => NAMESPACE_MODEL::Command.new(NAMESPACE_SPEC::VERSION)
        }.freeze

        def initialize(plugin, argv, env, registry)
          @plugin   = plugin
          @argv     = argv
          @env      = env
          @registry = registry

          @internal = {
            'help'    => NAMESPACE_CMD::Help.new(env, registry),
            'version' => NAMESPACE_CMD::Version.new(env)
          }
        end

        def run(command, args = nil)
          return nil unless @internal.key?(command)

          @internal[command].execute(args || run_argv)
        end

        private

        def run_argv
          argv = @argv.dup

          argv.shift if argv_has_box_name?
          argv.shift
          argv
        end

        def argv_has_box_name?
          VagrantPlugins::DevCommands::Util.box_name?(@env, @argv[0].to_s)
        end
      end
    end
  end
end
