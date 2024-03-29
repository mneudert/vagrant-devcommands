# frozen_string_literal: true

module VagrantPlugins
  module DevCommands
    class Registry
      # Generic registry message printer
      class Messager
        I18N_KEY = 'vagrant_devcommands.registry'

        def initialize(env)
          @env = env
        end

        def chain_ignored(message, name)
          @env.ui.warn I18n.t("#{I18N_KEY}.#{message}", name: name)
          @env.ui.warn I18n.t("#{I18N_KEY}.chain_ignored")
        end

        def command_alias_ignored(message, name)
          @env.ui.warn I18n.t("#{I18N_KEY}.#{message}", name: name)
          @env.ui.warn I18n.t("#{I18N_KEY}.command_alias_ignored")
        end

        def def_duplicate(args)
          @env.ui.warn I18n.t("#{I18N_KEY}.def_duplicate", **args)
          @env.ui.warn ''
        end

        def def_ignored(message, args)
          @env.ui.warn I18n.t("#{I18N_KEY}.#{message}", **args)
          @env.ui.warn I18n.t("#{I18N_KEY}.def_ignored")
          @env.ui.warn ''
        end

        def unknown_options(args)
          @env.ui.warn I18n.t("#{I18N_KEY}.unknown_options", **args)
          @env.ui.warn ''
        end
      end
    end
  end
end
