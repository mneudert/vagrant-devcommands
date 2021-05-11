# frozen_string_literal: true

require 'optparse'

module VagrantPlugins
  module DevCommands
    module Model
      # Definition of a command alias
      class CommandAlias
        attr_reader :name, :argv, :command, :machine, :desc, :help, :usage

        def initialize(spec)
          @name = spec[:name]

          @argv    = spec[:argv] || []
          @command = spec[:command]

          @machine = spec[:machine]
          @desc    = spec[:desc]
          @help    = spec[:help]
          @usage   = spec[:usage]
        end
      end
    end
  end
end
