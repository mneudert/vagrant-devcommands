# frozen_string_literal: true

module VagrantPlugins
  module DevCommands
    module Model
      # Definition of an executable command chain
      class Chain
        attr_reader :name
        attr_reader :commands

        attr_reader :desc
        attr_reader :help
        attr_reader :usage

        def initialize(spec)
          @name     = spec[:name]
          @commands = spec[:commands]

          @desc  = spec[:desc]
          @help  = spec[:help]
          @usage = spec[:usage]

          @break_on_error = spec[:break_on_error] != false
        end

        def break_on_error?
          @break_on_error
        end
      end
    end
  end
end
