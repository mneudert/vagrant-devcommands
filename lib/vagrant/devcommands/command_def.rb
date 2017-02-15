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

        opts = {}
        opts = parse_argv(argv) if @parameters

        (script % opts).strip
      end

      private

      def escape_option_values(options)
        @parameters.each do |key, conf|
          next if conf[:escape].nil?

          conf[:escape].each do |char, with|
            char         = char.to_s unless char.is_a?(String)
            options[key] = options[key].sub(char, "#{with}#{char}")
          end
        end

        options
      end

      def options_with_defaults
        options = {}

        @parameters.each do |key, conf|
          options[key] = '' if conf[:optional]
          options[key] = conf[:default] unless conf[:default].nil?
        end

        options
      end

      def parse_argv(argv)
        options = options_with_defaults

        OptionParser.new do |opts|
          @parameters.each do |key, _conf|
            opts.on("--#{key} OPTION", "Parameter: #{key}") do |o|
              options[key] = o
            end
          end
        end.parse!(argv)

        wrap_option_values(escape_option_values(options))
      end

      def wrap_option_values(options)
        @parameters.each do |key, conf|
          next if conf[:wrap].nil?

          if conf[:default].nil?
            next if options[key].nil? || options[key].empty?
          end

          options[key] = conf[:wrap] % options[key]
        end

        options
      end
    end
  end
end
