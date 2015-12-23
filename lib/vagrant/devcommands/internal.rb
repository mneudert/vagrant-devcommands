module VagrantPlugins
  module DevCommands
    # Handles internal commands and their execution.
    class Internal
      NAMESPACE = VagrantPlugins::DevCommands::InternalCommand

      SPECS = {
        'help' => NAMESPACE::Help::SPEC,
        'version' => NAMESPACE::Version::SPEC
      }

      def initialize(registry)
        @internal = {
          'help'    => NAMESPACE::Help.new(registry),
          'version' => NAMESPACE::Version.new
        }
        @registry = registry
      end

      def run(command, args)
        @internal[command].execute(args) if @internal.key?(command)
      end
    end
  end
end
