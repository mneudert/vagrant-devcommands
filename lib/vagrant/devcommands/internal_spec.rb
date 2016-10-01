module VagrantPlugins
  module DevCommands
    # Contains the specs for internal commands
    class InternalSpec
      I18N_KEY = 'vagrant_devcommands.internal'.freeze

      HELP = {
        desc:  I18n.t("#{I18N_KEY}.help.desc"),
        name:  'help',
        usage: 'vagrant run %{command} [command]',
        help:  I18n.t("#{I18N_KEY}.help.help")
      }.freeze

      VERSION = {
        desc:  I18n.t("#{I18N_KEY}.version.desc"),
        name:  'version',
        usage: 'vagrant run %{command}',
        help:  I18n.t("#{I18N_KEY}.version.help")
      }.freeze
    end
  end
end
