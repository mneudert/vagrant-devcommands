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
          return message(:chain_no_help) if help.nil?

          info(help.strip, true)
        end

        def commands(chain)
          info('Chained commands (in order):', true)

          command_list = chain.commands.each { |cmd| cmd[:command] }
          pad_to       = UTIL.pad_to(command_list)

          chain.commands.each do |cmd, _options|
            info(UTIL.padded_columns(pad_to, cmd[:command]))
          end
        end

        def header(chain)
          info("Usage: vagrant run [box] #{chain.name}")
        end

        def info(msg, pre_ln = false)
          @env.ui.info '' if pre_ln
          @env.ui.info msg
        end

        def message(msg)
          MESSAGES.public_send(msg, &@env.ui.method(:info))
        end
      end
    end
  end
end
