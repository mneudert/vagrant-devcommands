require 'pathname'

module VagrantPlugins
  module DevCommands
    # Loads and handles the Commandfile
    class CommandFile
      def initialize(env)
        @env = env
      end

      def exist?
        nil != path
      end

      def path
        find_commandfile
      end

      def path_global
        global = Pathname.new(Dir.home).join('.vagrant.devcommands')

        return global if global.file?

        nil
      end

      private

      attr_accessor :env

      def find_commandfile
        return nil unless @env.root_path

        %w(Commandfile commandfile).each do |commandfile|
          current_path = @env.root_path.join(commandfile)

          return current_path if current_path.file?
        end

        nil
      end
    end
  end
end
