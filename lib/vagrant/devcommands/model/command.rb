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

        attr_reader :machine
        attr_reader :desc
        attr_reader :help
        attr_reader :usage

        attr_reader :deprecated_box_config

        def initialize(spec)
          @name = spec[:name]

          @flags      = spec[:flags]
          @parameters = spec[:parameters]
          @script     = spec[:script]

          @machine = spec[:machine] || spec[:box]
          @desc    = spec[:desc]
          @help    = spec[:help]
          @usage   = spec[:usage]

          @deprecated_box_config = spec.key?(:box)
        end

        def run_script(argv)
          script = @script
          script = script.call if script.is_a?(Proc)

          opts = {}
          opts = parse_argv(argv) if @flags || @parameters

          (script % opts).strip
        end

        private

        def escape_parameters(params)
          (@parameters || {}).each do |key, conf|
            next if conf[:escape].nil?

            conf[:escape].each do |char, with|
              char        = char.to_s unless char.is_a?(String)
              params[key] = params[key].sub(char, "#{with}#{char}")
            end
          end

          params
        end

        def parameters_with_defaults
          params = {}

          (@parameters || {}).each do |key, conf|
            params[key] = '' if conf[:optional]
            params[key] = conf[:default] unless conf[:default].nil?
          end

          params
        end

        # rubocop:disable Metrics/MethodLength
        def parse_argv(argv)
          params = parameters_with_defaults

          OptionParser.new do |opts|
            (@flags || {}).each do |key, conf|
              params[key] = ''

              opts.on("--#{key}", "Flag: #{key}") do
                params[key] = conf[:value] || "--#{key}"
              end
            end

            (@parameters || {}).each do |key, _conf|
              opts.on("--#{key} OPTION", "Parameter: #{key}") do |o|
                params[key] = o
              end
            end
          end.parse!(argv)

          wrap_parameters(validate_parameters(escape_parameters(params)))
        end
        # rubocop:enable Metrics/MethodLength

        def validate_parameters(params)
          (@parameters || {}).each do |key, conf|
            next if conf[:allowed].nil?
            next if conf[:allowed].include?(params[key])

            raise ArgumentError, "--#{key}=#{params[key]}"
          end

          params
        end

        def wrap_parameters(params)
          (@parameters || {}).each do |key, conf|
            next if conf[:wrap].nil?

            if conf[:default].nil?
              next if params[key].nil? || params[key].empty?
            end

            params[key] = conf[:wrap] % params[key]
          end

          params
        end
      end
    end
  end
end
