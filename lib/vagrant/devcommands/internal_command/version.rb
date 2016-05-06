module VagrantPlugins
  module DevCommands
    module InternalCommand
      # Internal "version" command
      class Version
        SPEC = {
          desc:  I18n.t('vagrant_devcommands.internal.version.desc'),
          name:  'version',
          usage: 'vagrant run %{command}',
          help:  I18n.t('vagrant_devcommands.internal.version.help')
        }.freeze

        def initialize(env)
          @env = env
        end

        def execute(_args)
          @env.ui.info "vagrant-devcommands, version #{VERSION}"
        end
      end
    end
  end
end
