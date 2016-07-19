module VagrantPlugins
  module DevCommands
    # Contains the specs for internal commands
    class InternalSpec
      HELP = {
        desc:  I18n.t('vagrant_devcommands.internal.help.desc'),
        name:  'help',
        usage: 'vagrant run %{command} [command]',
        help:  I18n.t('vagrant_devcommands.internal.help.help')
      }.freeze

      VERSION = {
        desc:  I18n.t('vagrant_devcommands.internal.version.desc'),
        name:  'version',
        usage: 'vagrant run %{command}',
        help:  I18n.t('vagrant_devcommands.internal.version.help')
      }.freeze
    end
  end
end
