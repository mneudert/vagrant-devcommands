# frozen_string_literal: true

module VagrantPlugins
  module DevCommands
    # Contains the specs for internal commands
    class InternalSpec
      I18N_KEY = 'vagrant_devcommands.internal'

      COMPLETION_DATA = {
        desc: I18n.t("#{I18N_KEY}.completion-data.desc"),
        name: 'completion-data',
        usage: 'vagrant run %<command>s',
        help: I18n.t("#{I18N_KEY}.completion-data.help")
      }.freeze

      HELP = {
        desc: I18n.t("#{I18N_KEY}.help.desc"),
        name: 'help',
        usage: 'vagrant run %<command>s [command]',
        help: I18n.t("#{I18N_KEY}.help.help")
      }.freeze

      VERSION = {
        desc: I18n.t("#{I18N_KEY}.version.desc"),
        name: 'version',
        usage: 'vagrant run %<command>s',
        help: I18n.t("#{I18N_KEY}.version.help")
      }.freeze
    end
  end
end
