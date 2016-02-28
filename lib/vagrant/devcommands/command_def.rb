module VagrantPlugins
  module DevCommands
    # Definition of an executable command
    class CommandDef
      attr_reader :name
      attr_reader :script

      attr_reader :box
      attr_reader :desc
      attr_reader :help
      attr_reader :usage

      def initialize(spec)
        @name   = spec[:name]
        @script = spec[:script]

        @box   = spec[:box]
        @desc  = spec[:desc]
        @help  = spec[:help]
        @usage = spec[:usage]
      end
    end
  end
end
