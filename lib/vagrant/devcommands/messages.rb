# frozen_string_literal: true

require 'optparse'

module VagrantPlugins
  module DevCommands
    # Provides access to messages used by the plugin
    class Messages
      I18N_KEY = 'vagrant_devcommands.message'

      def self.chain_no_help
        yield I18n.t("#{I18N_KEY}.chain_no_help")
      end

      def self.command_alias_no_help
        yield I18n.t("#{I18N_KEY}.command_alias_no_help")
      end

      def self.command_no_help
        yield I18n.t("#{I18N_KEY}.command_no_help")
      end

      def self.missing_commandfile
        yield I18n.t("#{I18N_KEY}.missing_commandfile")
      end

      def self.no_commands
        yield I18n.t("#{I18N_KEY}.no_commands")
      end

      def self.plugin_readme
        curdir = File.expand_path(__dir__)
        readme = File.expand_path(File.join(curdir, '../../../README.md'))

        yield I18n.t("#{I18N_KEY}.plugin_readme", readme: readme)
      end

      def self.plugin_usage
        yield I18n.t("#{I18N_KEY}.plugin_usage")
      end

      def self.pre_ln(msg, &out)
        yield ''

        public_send(msg, &out)
      end
    end
  end
end
