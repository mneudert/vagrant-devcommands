require 'optparse'

module VagrantPlugins
  module DevCommands
    module Model
      # Definition of a command alias
      class CommandAlias
        attr_reader :name

        attr_reader :argv
        attr_reader :command
        attr_reader :desc
        attr_reader :help
        attr_reader :usage

        def initialize(spec)
          @name = spec[:name]

          @argv    = spec[:argv] || []
          @command = spec[:command]
          @desc    = spec[:desc]
          @help    = spec[:help]
          @usage   = spec[:usage]
        end
      end
    end
  end
end
