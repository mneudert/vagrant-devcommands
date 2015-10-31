module VagrantPlugins
  module DevCommands
    # Loads and handles the Commandfile
    class Commandfile
      def initialize(env)
        @env = env
      end

      def exist?
        nil != find_commandfile
      end

      def path
        find_commandfile
      end

      def import
        load path
      end

      private

      attr_reader :env
      attr_writer :env

      def find_commandfile
        %w(Commandfile commandfile).each do |commandfile|
          current_path = @env.root_path.join(commandfile)

          return current_path if current_path.file?
        end

        nil
      end
    end
  end
end
