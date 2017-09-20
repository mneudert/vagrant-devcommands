module VagrantPlugins
  module DevCommands
    module HelpPrinter
      # Prints help for a command chain
      class Chain
        UTIL     = VagrantPlugins::DevCommands::Util
        MESSAGES = VagrantPlugins::DevCommands::Messages

        def initialize(env)
          @env = env
        end

        def output(chain)
          header(chain)
          commands(chain)
          body(chain.help)
        end

        private

        def body(help)
          return message(:chain_no_help, true) if help.nil?

          info(help.strip, true)
        end

        def chain_help_line(cmd)
          return cmd[:command] unless cmd.key?(:argv)

          "#{cmd[:command]} #{cmd[:argv]}"
        end

        def commands(chain)
          info('Chained commands (in order):', true)

          chain.commands.each do |cmd|
            info(UTIL.padded_columns(0, chain_help_line(cmd)))
          end
        end

        def header(chain)
          usage =
            if chain.usage.nil?
              "vagrant run [machine] #{chain.name}"
            else
              format(chain.usage, chain: chain.name)
            end

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
