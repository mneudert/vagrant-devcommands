# frozen_string_literal: true

module VagrantPlugins
  module DevCommands
    class Commandfile
      # Provides the DSL to read the contents of a Commandfile
      class Reader
        attr_reader :entries

        def initialize(commandfile, env)
          @commandfile = commandfile
          @env         = env

          @entries = []
        end

        def read
          global = @commandfile.path_global
          local  = @commandfile.path

          contents = ''
          contents += "\n#{global.read}" unless global.nil?
          contents += "\n#{local.read}" unless local.nil?

          instance_eval(contents)

          @entries
        end

        private

        def chain(name, options = nil)
          @entries << {
            type: :chain,
            name: name.to_s,
            options: options
          }
        end

        def command(name, options = nil)
          @entries << {
            type: :command,
            name: name.to_s,
            options: options
          }
        end

        def command_alias(name, options = nil)
          @entries << {
            type: :command_alias,
            name: name.to_s,
            options: options
          }
        end
      end
    end
  end
end
