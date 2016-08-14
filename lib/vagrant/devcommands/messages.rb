require 'optparse'

module VagrantPlugins
  module DevCommands
    # Provides access to messages used by the plugin
    class Messages
      def self.no_help(&out)
        out.call 'No detailed help for this command available.'
      end

      def self.no_commands(&out)
        out.call 'No commands defined!'
      end

      def self.plugin_usage(&out)
        out.call 'Usage: vagrant run [box] <command>'
        out.call 'Help:  vagrant run help <command>'
      end
    end
  end
end
