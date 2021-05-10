# frozen_string_literal: true

module VagrantPlugins
  module DevCommands
    module HelpPrinter
      # Prints help for a command
      class Command
        I18N_KEY = 'vagrant_devcommands.internal.help'
        UTIL     = VagrantPlugins::DevCommands::Util
        MESSAGES = VagrantPlugins::DevCommands::Messages

        def initialize(env)
          @env = env
        end

        def output(command)
          header(command)
          arguments(command.parameters, 'Parameters')
          arguments(command.flags, 'Flags')
          body(command.help)
        end

        private

        def arguments(arguments, title)
          return if arguments.nil? || arguments.empty?

          info("#{title}:", pre_ln: true)
          arguments_body(arguments)
        end

        def arguments_body(arguments)
          pad_to = UTIL.pad_to(arguments)

          arguments.sort.each do |name, options|
            info(UTIL.padded_columns(pad_to, name, options[:desc]))
          end
        end

        def body(help)
          return message(:command_no_help, pre_ln: true) if help.nil?

          info(help.strip, pre_ln: true)
        end

        def header(command)
          usage =
            if command.usage.nil?
              usage_params(
                I18n.t("#{I18N_KEY}.usage_default", what: command.name),
                command
              )
            else
              format(command.usage, command: command.name)
            end

          info(I18n.t("#{I18N_KEY}.usage", what: usage))
        end

        def info(msg, pre_ln: false)
          @env.ui.info '' if pre_ln
          @env.ui.info msg
        end

        def message(msg, pre_ln: false)
          if pre_ln
            MESSAGES.pre_ln(msg, &@env.ui.method(:info))
          else
            MESSAGES.public_send(msg, &@env.ui.method(:info))
          end
        end

        def usage_params(usage, command)
          [
            usage,
            UTIL.collect_mandatory_params(command.parameters),
            UTIL.collect_optional_params(command.parameters),
            UTIL.collect_flags(command.flags)
          ].flatten.compact.join(' ').strip
        end
      end
    end
  end
end
