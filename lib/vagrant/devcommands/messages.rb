require 'optparse'

module VagrantPlugins
  module DevCommands
    # Provides access to messages used by the plugin
    class Messages
      def self.missing_commandfile(&out)
        out.call 'Missing Commandfile'
      end

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

      def self.plugin_usage_info(&out)
        curdir = File.expand_path(File.dirname(__FILE__))
        readme = File.expand_path(File.join(curdir, '../../../README.md'))

        out.call ''
        out.call 'For detailed plugin usage information please read'
        out.call 'the README.md at the original source location:'
        out.call '>>> https://github.com/mneudert/vagrant-devcommands'
        out.call 'A copy of this file should be locally available at:'
        out.call ">>> #{readme}"
      end
    end
  end
end
