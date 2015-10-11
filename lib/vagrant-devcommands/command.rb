module VagrantPlugins
  module DevCommands
    class Command < Vagrant.plugin(2, :command)

      def self.synopsis
        ''
      end

      def execute
        puts 'Hello, Plugin!'

        return 0
      end

    end
  end
end
