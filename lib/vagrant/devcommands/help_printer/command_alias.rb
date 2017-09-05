module VagrantPlugins
  module DevCommands
    module HelpPrinter
      # Prints help for a command alias
      class CommandAlias
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
          usage = "vagrant run [machine] #{command_alias.name}"

          info(I18n.t('vagrant_devcommands.internal.help.usage', what: usage))
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
