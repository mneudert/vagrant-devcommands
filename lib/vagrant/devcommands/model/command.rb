require 'optparse'

module VagrantPlugins
  module DevCommands
    module Model
      # Definition of an executable command
      class Command
        attr_reader :name

        attr_reader :flags
        attr_reader :parameters
        attr_reader :script

        attr_reader :box
        attr_reader :desc
        attr_reader :help
        attr_reader :usage

        def initialize(spec)
          @name = spec[:name]

          @flags      = spec[:flags]
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
          opts = parse_argv(argv) if @flags || @parameters

          (script % opts).strip
        end

        private

        def escape_option_values(options)
          (@parameters || {}).each do |key, conf|
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

          (@parameters || {}).each do |key, conf|
            options[key] = '' if conf[:optional]
            options[key] = conf[:default] unless conf[:default].nil?
          end

          options
        end

        # rubocop:disable Metrics/MethodLength
        def parse_argv(argv)
          options = options_with_defaults

          OptionParser.new do |opts|
            (@flags || {}).each do |key, _conf|
              options[key] = ''

              opts.on("--#{key}", "Flag: #{key}") do
                options[key] = "--#{key}"
              end
            end

            (@parameters || {}).each do |key, _conf|
              opts.on("--#{key} OPTION", "Parameter: #{key}") do |o|
                options[key] = o
              end
            end
          end.parse!(argv)

          wrap_option_values(escape_option_values(options))
        end

        def wrap_option_values(options)
          (@parameters || {}).each do |key, conf|
            next if conf[:wrap].nil?
            next if options[key].nil? && conf[:default].nil?

            options[key] = conf[:wrap] % options[key]
          end

          options
        end
      end
    end
  end
end
