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
        end
      end
    end
  end
end
