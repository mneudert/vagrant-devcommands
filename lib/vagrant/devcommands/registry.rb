module VagrantPlugins
  module DevCommands
    # Vagrant command registry
    class Registry
      attr_accessor :commands

      def initialize
        @commands = {}
      end

      def read_commandfile(commandfile)
        contents = commandfile.path.read

        instance_eval(contents)
        append_legacy
      end

      def valid_command?(command)
        @commands.include? command
      end

      private

      def append_legacy
        unless Definer.commands.empty?
          puts "You are using a deprecated way of defining your commands.\n" \
               'The methods you are using will be removed in an upcoming' \
               " release.\nPlease update your Commandfile!\n\nMore details: " \
               'https://github.com/mneudert/vagrant-devcommands'
        end

        Definer.commands.each do |name, options|
          next if @commands.include?(name)

          command(name, options)
        end
      end

      def command(name, options)
        if options.is_a?(String)
          @commands[name] = { script: options }
        else
          @commands[name] = options
        end
      end
    end
  end
end
