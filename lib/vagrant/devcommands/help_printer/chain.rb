# frozen_string_literal: true

module VagrantPlugins
  module DevCommands
    module HelpPrinter
      # Prints help for a command chain
      class Chain
        I18N_KEY = 'vagrant_devcommands.internal.help'
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
          return message(:chain_no_help, pre_ln: true) if help.nil?

          info(help.strip, pre_ln: true)
        end

        def chain_help_line(cmd)
          return cmd[:command] unless cmd.key?(:argv)

          "#{cmd[:command]} #{cmd[:argv]}"
        end

        def commands(chain)
          info('Chained commands (in order):', pre_ln: true)

          chain.commands.each do |cmd|
            info(UTIL.padded_columns(0, chain_help_line(cmd)))
          end
        end

        def header(chain)
          usage =
            if chain.usage.nil?
              I18n.t("#{I18N_KEY}.usage_default", what: chain.name)
            else
              format(chain.usage, chain: chain.name)
            end

          info(I18n.t("#{I18N_KEY}.usage", what: usage))
        end

        def info(msg, pre_ln: false)
          @env.ui.info '' if pre_ln
          @env.ui.info msg
        end

        def message(msg, pre_ln: false)
          if pre_ln
            MESSAGES.pre_ln(msg) { |m| @env.ui.info(m) }
          else
            MESSAGES.public_send(msg) { |m| @env.ui.info(m) }
          end
        end
      end
    end
  end
end
