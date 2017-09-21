module VagrantPlugins
  module DevCommands
    module HelpPrinter
      # Prints help for a command alias
      class CommandAlias
        I18N_KEY = 'vagrant_devcommands.internal.help'.freeze
        UTIL     = VagrantPlugins::DevCommands::Util
        MESSAGES = VagrantPlugins::DevCommands::Messages

        def initialize(env)
          @env = env
        end

        def output(command_alias)
          header(command_alias)
          body(command_alias.help)
        end

        private

        def body(help)
          return message(:command_alias_no_help, true) if help.nil?

          info(help.strip, true)
        end

        def header(command_alias)
          usage =
            if command_alias.usage.nil?
              "vagrant run [machine] #{command_alias.name}"
            else
              format(command_alias.usage, command_alias: command_alias.name)
            end

          alias_for = [command_alias.command, command_alias.argv].join(' ')

          info(I18n.t("#{I18N_KEY}.usage", what: usage))
          info(I18n.t("#{I18N_KEY}.alias_for", what: alias_for), true)
        end

        def info(msg, pre_ln = false)
          @env.ui.info '' if pre_ln
          @env.ui.info msg
        end

        def message(msg, pre_ln = false)
          if pre_ln
            MESSAGES.pre_ln(msg, &@env.ui.method(:info))
          else
            MESSAGES.public_send(msg, &@env.ui.method(:info))
          end
        end
      end
    end
  end
end
