module VagrantPlugins
  module DevCommands
    # Handles internal commands and their execution.
    class Internal
      NAMESPACE = VagrantPlugins::DevCommands::InternalCommand

      COMMANDS = {
        'help'    => CommandDef.new(NAMESPACE::Help::SPEC),
        'version' => CommandDef.new(NAMESPACE::Version::SPEC)
      }.freeze

      def initialize(registry, env)
        @internal = {
          'help'    => NAMESPACE::Help.new(registry),
          'version' => NAMESPACE::Version.new(env)
        }
        @registry = registry
      end

      def run(command, args)
        @internal[command].execute(args) if @internal.key?(command)
      end
    end
  end
end
