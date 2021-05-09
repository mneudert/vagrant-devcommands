# frozen_string_literal: true

require 'optparse'

module VagrantPlugins
  module DevCommands
    # Command Parameter Parser
    class ParamParser
      def parse!(command, argv)
        return {} if command.flags.empty? && command.parameters.empty?

        params = parse_argv(command, argv)
        params = unalias_parameters(command, params)
        params = validate_parameters(command, params)
        params = escape_parameters(command, params)
        params = wrap_parameters(command, params)
        params
      end

      private

      def escape_parameters(command, params)
        command.parameters.each do |key, conf|
          next if conf[:escape].nil?

          conf[:escape].each do |char, with|
            char        = char.to_s unless char.is_a?(String)
            params[key] = params[key].sub(char, "#{with}#{char}")
          end
        end

        params
      end

      def parameters_with_defaults(command)
        params = {}

        command.parameters.each do |key, conf|
          params[key] = '' if conf[:optional]
          params[key] = conf[:default] unless conf[:default].nil?
        end

        params
      end

      # rubocop:disable Metrics/MethodLength
      def parse_argv(command, argv)
        params = parameters_with_defaults(command)

        begin
          OptionParser.new do |opts|
            command.flags.each do |key, conf|
              params[key] = ''

              opts.on("--#{key}", "Flag: #{key}") do
                params[key] = conf[:value] || "--#{key}"
              end
            end

            command.parameters.each_key do |key|
              opts.on("--#{key} OPTION", "Parameter: #{key}") do |o|
                params[key] = o
              end
            end
          end.parse!(argv)
        rescue OptionParser::InvalidOption => e
          e.recover(argv)
        end

        params = passthru_parameters(params, command, argv) unless argv.empty?
        params
      end
      # rubocop:enable Metrics/MethodLength

      def passthru_parameters(params, command, argv)
        has_passthru = false

        command.parameters.each do |key, conf|
          next unless conf[:passthru]

          params[key]  = argv.join(' ')
          has_passthru = true
        end

        raise OptionParser::InvalidOption, argv unless has_passthru

        params
      end

      def unalias_parameters(command, params)
        command.parameters.each do |key, conf|
          next if params[key].nil?
          next if conf[:aliases].nil?

          conf[:aliases].each do |input, output|
            params[key] = params[key] == input ? output : params[key]
          end
        end

        params
      end

      def validate_parameters(command, params)
        command.parameters.each do |key, conf|
          next if params[key].nil?
          next if params[key] == '' && conf[:optional]

          next if conf[:allowed].nil?
          next if conf[:allowed].include?(params[key])

          raise ArgumentError, "--#{key}=#{params[key]}"
        end

        params
      end

      def wrap_parameters(command, params)
        command.parameters.each do |key, conf|
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
