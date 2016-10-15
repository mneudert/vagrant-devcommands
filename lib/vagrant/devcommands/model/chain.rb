module VagrantPlugins
  module DevCommands
    module Model
      # Definition of an executable command chain
      class Chain
        attr_reader :name
        attr_reader :commands

        attr_reader :desc
        attr_reader :help

        def initialize(spec)
          @name     = spec[:name]
          @commands = spec[:commands]

          @desc = spec[:desc]
          @help = spec[:help]

          @break_on_error = false != spec[:break_on_error]
        end

        def break_on_error?
          @break_on_error
        end
      end
    end
  end
end
