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

        command = @argv.pop()

        if !command
          list_commands()
          return 127
        end

        run command
      end


      private

      def command_file_path
        File.join @env.cwd, 'Commandfile'
      end

      def import_commands(command_file)
        load command_file
      end

      def list_commands()
        if Definer.commands.empty?
          puts 'No commands defined!'
          return
        end

        puts "Available commands:"

        Definer.commands.each_key do | name |
          puts "- #{ name }"
        end

        puts ''
        puts 'Usage: vagrant run <command>'
      end

      def run(name)
        if !valid_command?(name)
          puts "Invalid command \"#{ name }\""
          return 1
        end

        cmd = Definer.commands[name]

        if cmd[:box] and 0 == @argv.size
          @argv.unshift(cmd[:box].to_s)
        elsif cmd[:box] and 1 == @argv.size
          @argv[0] = cmd[:box].to_s
        end

        with_target_vms(@argv, single_target: true) do |vm|
          env = vm.action(:ssh_run,
                          ssh_opts: { extra_args: [ '-q' ]},
                          ssh_run_command: cmd[:command])

          return env[:ssh_run_exit_status] || 0
        end

        return 0
      end

      def valid_command?(command)
        Definer.commands.include? command
      end

    end
  end
end
