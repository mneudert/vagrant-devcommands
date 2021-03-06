# frozen_string_literal: true

module VagrantPlugins
  module DevCommands
    class Commandfile
      # Converts a (commandfile) entry into a model instance
      class Modeler
        def model(spec)
          case spec[:type]
          when :chain
            chain(spec[:name], spec[:options])
          when :command
            command(spec[:name], spec[:options])
          when :command_alias
            command_alias(spec[:name], spec[:options])
          end
        end

        private

        def chain(name, options)
          options            = {} unless options.is_a?(Hash)
          options[:commands] = {} unless options.key?(:commands)
          options[:name]     = name

          raise ArgumentError, 'chain_empty' if options[:commands].empty?
          raise ArgumentError, 'chain_name_space' if name.include?(' ')

          VagrantPlugins::DevCommands::Model::Chain.new(options)
        end

        def command(name, options)
          raise ArgumentError, 'command_name_space' if name.include?(' ')

          options        = { script: options } unless options.is_a?(Hash)
          options[:name] = name

          raise ArgumentError, 'command_no_script' unless valid_script?(options[:script])

          VagrantPlugins::DevCommands::Model::Command.new(options)
        end

        def command_alias(name, options)
          raise ArgumentError, 'command_alias_name_space' if name.include?(' ')

          options        = { command: options } unless options.is_a?(Hash)
          options[:name] = name

          raise ArgumentError, 'command_alias_empty' unless options[:command]

          VagrantPlugins::DevCommands::Model::CommandAlias.new(options)
        end

        def valid_script?(script)
          return true if script.is_a?(Proc)

          return false unless script.is_a?(String)
          return false if script.empty?

          true
        end
      end
    end
  end
end
