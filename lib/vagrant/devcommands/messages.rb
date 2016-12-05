require 'optparse'

module VagrantPlugins
  module DevCommands
    # Provides access to messages used by the plugin
    class Messages
      I18N_KEY = 'vagrant_devcommands.message'.freeze

      def self.chain_no_help(&out)
        out.call I18n.t("#{I18N_KEY}.chain_no_help")
      end

      def self.command_no_help(&out)
        out.call I18n.t("#{I18N_KEY}.command_no_help")
      end

      def self.missing_commandfile(&out)
        out.call I18n.t("#{I18N_KEY}.missing_commandfile")
      end

      def self.no_commands(&out)
        out.call I18n.t("#{I18N_KEY}.no_commands")
      end

      def self.plugin_usage(&out)
        out.call I18n.t("#{I18N_KEY}.plugin_usage")
      end

      def self.plugin_usage_info(&out)
        curdir = File.expand_path(File.dirname(__FILE__))
        readme = File.expand_path(File.join(curdir, '../../../README.md'))

        out.call I18n.t("#{I18N_KEY}.plugin_usage_info", readme: readme)
      end

      def self.pre_ln(msg, &out)
        out.call ''

        public_send(msg, &out)
      end
    end
  end
end
