module VagrantPlugins
  module DevCommands
    class Command < Vagrant.plugin(2, :command)

      def self.synopsis
        'runs vagrant commands from a Commandfile'
      end

      def execute
        command_file = command_file_path()

        if !File.exist?(command_file)
          puts 'missing "Commandfile"'
          return 1
        end

        puts "found \"Commandfile\" at path: #{ command_file }"

        return 0
      end


      private

      def command_file_path
        File.join @env.cwd, 'Commandfile'
      end

    end
  end
end
