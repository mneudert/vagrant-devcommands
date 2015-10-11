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

        import_commands(command_file)
        list_commands()

        return 0
      end


      private

      def command_file_path
        File.join @env.cwd, 'Commandfile'
      end

      def import_commands(command_file)
        load command_file
      end

      def list_commands()
        if Vagrant::DevCommand.commands.empty?
          puts 'No commands defined!'
          return
        end

        puts "Available commands:"

        Vagrant::DevCommand.commands.each_key do | name |
          puts "- #{ name }"
        end

        puts ''
        puts 'Usage: vagrant run <command>'
      end

    end
  end
end
