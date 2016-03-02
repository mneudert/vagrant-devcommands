require 'optparse'

module VagrantPlugins
  module DevCommands
    # Definition of an executable command
    class CommandDef
      attr_reader :name
      attr_reader :parameters
      attr_reader :script

      attr_reader :box
      attr_reader :desc
      attr_reader :help
      attr_reader :usage

      def initialize(spec)
        @name       = spec[:name]
        @parameters = spec[:parameters]
        @script     = spec[:script]

        @box   = spec[:box]
        @desc  = spec[:desc]
        @help  = spec[:help]
        @usage = spec[:usage]
      end

      def run_script(argv)
        script = @script
        script = script.call if script.is_a?(Proc)

        opts = []
        opts = parse_argv(argv) if @parameters

        (script % opts).strip
      end

      private

      def parse_argv(argv)
        options = options_with_defaults

        OptionParser.new do |opts|
          @parameters.each do |key, _conf|
            opts.on("--#{key} OPTION", "Parameter: #{key}") do |o|
              options[key] = o
            end
          end
        end.parse!(argv)

        options
      end

      def options_with_defaults
        options = {}

        @parameters.each do |key, conf|
          options[key] = '' if conf[:optional]
        end

        options
      end
    end
  end
end
