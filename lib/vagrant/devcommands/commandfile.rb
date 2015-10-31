module VagrantPlugins
  module DevCommands
    # Loads and handles the Commandfile
    class Commandfile
      def initialize(env)
        @env = env
      end

      def exist?
        File.exist? path
      end

      def path
        File.join @env.root_path, 'Commandfile'
      end

      def import
        load path
      end

      private

      attr_reader :env
      attr_writer :env
    end
  end
end
