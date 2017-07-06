require 'optparse'

module VagrantPlugins
  module DevCommands
    module Model
      # Definition of a command alias
      class CommandAlias
        attr_reader :name

        attr_reader :command

        def initialize(spec)
          @name = spec[:name]

          @command = spec[:command]
        end
      end
    end
  end
end
