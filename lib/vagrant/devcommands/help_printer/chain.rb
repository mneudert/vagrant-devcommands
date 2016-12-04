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

          pad_to = UTIL.pad_to(chain.commands)

          chain.commands.each do |name, _options|
            info(UTIL.padded_columns(pad_to, name))
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