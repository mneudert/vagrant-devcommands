module VagrantPlugins
  module DevCommands
    # Public interface to define and access commands.
    class Definer
      class << self; attr_accessor :commands end

      @commands = {}

      def self.define(name, options)
        if options.is_a?(String)
          @commands[name] = { script: options }
        else
          if options.include?(:command)
            options[:script] = options[:command]

            options.delete(:command)
          end

          @commands[name] = options
        end
      end
    end
  end
end
